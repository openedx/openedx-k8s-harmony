terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  cluster_autoscaler_tags = var.enable_cluster_autoscaler ? {
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"             = "true"
  } : {}

  post_bootstrap_user_data = var.post_bootstrap_user_data != null ? var.post_bootstrap_user_data : templatefile(
    "${path.module}/templates/post_bootstrap_user_data.tpl",
    {
      registry_credentials = var.registry_credentials
    }
  )

  # Define the default IAM role additional policies for all the node groups
  # every element must define:
  #   - A key for the policy. It can be any string
  #   - A value which is the ARN of the policy to add
  #   - An enable key which determines if the policy is added or not
  node_group_defaults_iam_role_additional_policies = []
}

data "aws_ami" "latest_ubuntu_eks" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu-eks/k8s_${var.kubernetes_version}/images/hvm-ssd/ubuntu-${var.ubuntu_version}-amd64-server-*"]
  }
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Tier = "Private"
  }
}

module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~> 20.31"
  cluster_name                   = var.cluster_name
  cluster_version                = var.kubernetes_version
  cluster_endpoint_public_access = true
  vpc_id                         = data.aws_vpc.main.id
  subnet_ids                     = data.aws_subnets.main.ids
  enable_irsa                    = true
  cluster_tags                   = var.cluster_tags
  tags                           = var.tags

  create_cloudwatch_log_group = false
  cluster_enabled_log_types   = []

  cluster_addons = {
    coredns = {
      name = "coredns"
    }
    kube-proxy = {
      name = "kube-proxy"
    }
    vpc-cni = {
      name = "vpc-cni"
    }
    aws-ebs-csi-driver = {
      name                     = "aws-ebs-csi-driver"
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  # The security group rules below should not conflict with the recommended rules defined
  # here: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v19.21.0/node_groups.tf#L128
  node_security_group_additional_rules = {
    ssh_access = {
      description = "Grant access ssh access to the nodes"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      type        = "ingress"
      cidr_blocks = concat([data.aws_vpc.main.cidr_block], var.worker_node_extra_ssh_cidrs)
    }
  }

  # Disable secrets encryption
  cluster_encryption_config = {}

  iam_role_use_name_prefix = var.iam_role_use_name_prefix
  iam_role_name            = var.iam_role_name

  # for security group
  cluster_security_group_description     = var.cluster_security_group_description
  cluster_security_group_use_name_prefix = var.cluster_security_group_use_name_prefix
  cluster_security_group_name            = var.cluster_security_group_name

  eks_managed_node_group_defaults = {
    iam_role_additional_policies = { for s in local.node_group_defaults_iam_role_additional_policies : s.key => s.value if s.enable }
  }

  eks_managed_node_groups = {
    ubuntu_worker = {

      ami_id     = var.ami_id != "" ? var.ami_id : data.aws_ami.latest_ubuntu_eks.id
      key_name   = var.worker_node_ssh_key_name
      name       = var.worker_node_group_name
      subnet_ids = data.aws_subnets.main.ids

      # This will ensure the boostrap user data is used to join the node
      # By default, EKS managed node groups will not append bootstrap script;
      # this adds it back in using the default template provided by the module
      # Note: this assumes the AMI provided is an EKS optimized AMI derivative
      enable_bootstrap_user_data = true

      instance_types = var.worker_node_instance_types
      max_size       = var.max_worker_node_count
      min_size       = var.min_worker_node_count
      desired_size   = var.worker_node_count
      capacity_type  = var.worker_node_capacity_type

      create_security_group = false

      post_bootstrap_user_data = local.post_bootstrap_user_data

      block_device_mappings = {
        sda1 = {
          device_name = "/dev/sda1"
          ebs = {
            volume_size = var.worker_node_disk_size
          }
        }
      }

      tags = merge(var.worker_node_groups_tags, local.cluster_autoscaler_tags)
    }
  }
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.47"

  role_name             = "ebs-csi-controller-${var.cluster_name}"
  attach_ebs_csi_policy = true
  tags                  = var.tags

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

# Role required by cluster_autoscaler
module "cluster_autoscaler_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.47"

  count = var.enable_cluster_autoscaler ? 1 : 0

  role_name                        = "cluster-autoscaler-${module.eks.cluster_name}"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_name]
  tags                             = var.tags

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}
