#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster with one managed node group for EC2
#        plus a Fargate profile for serverless computing.
#
# Technical documentation:
# - https://docs.aws.amazon.com/kubernetes
# - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/
#
#------------------------------------------------------------------------------

locals {
  # Used by Karpenter config to determine correct partition (i.e. - `aws`, `aws-gov`, `aws-cn`, etc.)
  partition = data.aws_partition.current.partition

  tags = {
    "Name"                          = var.name
    "openedx-k8s-harmony/name"      = var.name
    "openedx-k8s-harmony/region"    = var.aws_region
    "openedx-k8s-harmony/terraform" = "true"
  }

}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 19.13"
  cluster_name                    = var.name
  cluster_version                 = var.kubernetes_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id                          = data.aws_vpc.reference.id
  subnet_ids                      = data.aws_subnets.private.ids
  create_cloudwatch_log_group     = false
  enable_irsa                     = true

  # NOTE:
  # by default Kubernetes secrets are encrypted with this key. Add your IAM
  # user ARN to the owner list in order to be able to view secrets.
  # AWS EKS KMS console: https://us-east-2.console.aws.amazon.com/kms/home
  #
  # audit your AWS EKS KMS key access by running:
  # aws kms get-key-policy --key-id ADD-YOUR-KEY-ID-HERE --region us-east-2 --policy-name default --output text
  create_kms_key = var.eks_create_kms_key
  kms_key_owners = var.kms_key_owners

  # Add your IAM user ARN to aws_auth_users in order to gain access to the cluster itself.
  # Note that alternatively, the cluster creator (presumably, you) can edit the manifest
  # for kube-system/aws-auth configMap, adding additional users and roles as needed.
  # see:
  manage_aws_auth_configmap = true
  aws_auth_users            = var.map_users

  tags = merge(
    local.tags,
    # Tag node group resources for Karpenter auto-discovery
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    { "karpenter.sh/discovery" = var.name }
  )

  # AWS EKS add-ons that are required in order to support persistent volume
  # claims for ElasticSearch and Caddy (if you opt for this rather than nginx).
  # Other addons are required by Karpenter and other optional supporting services.
  #
  # see: https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html
  cluster_addons = {
    # required to support internal networking between containers
    vpc-cni = {
      name = "vpc-cni"
    }
    # required to support internal DNS name resolution within the cluster
    coredns = {
      name = "coredns"
    }
    # required to maintain network rules on  nodes and to enable internal
    # network communication between pods.
    kube-proxy = {
      name = "kube-proxy"
    }
    # Required for release 1.22 and newer in order to support persistent volume
    # claims for ElasticSearch and Caddy (if you opt for this rather than nginx).
    aws-ebs-csi-driver = {
      name                     = "aws-ebs-csi-driver"
      service_account_role_arn = aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.arn
    }
  }

  # to enable internal https network communication between nodes.
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "openedx-k8s-harmony: Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = [
        "172.16.0.0/12",
        "192.168.0.0/16",
      ]
    }
    port_8443 = {
      description                = "openedx-k8s-harmony: open port 8443 to vpc"
      protocol                   = "-1"
      from_port                  = 8443
      to_port                    = 8443
      type                       = "ingress"
      source_node_security_group = true
    }
    egress_all = {
      description      = "openedx-k8s-harmony: Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_groups = {
    # This node group is managed by Karpenter. There must be at least one
    # node in this group at all times in order for Karpenter to monitor
    # load and act on metrics data. Karpenter's bin packing algorithms
    # perform more effectively with larger instance types. The default
    # instance type is t3.large (2 vCPU / 8 GiB). These instances,
    # beyond the 1 permanent instance, are assumed to be short-lived
    # (a few hours or less) as these are usually only instantiated during
    # bursts of user activity such as at the start of a scheduled lecture or
    # exam on a large mooc.
    service = {
      capacity_type     = "SPOT"
      enable_monitoring = false
      desired_size      = var.eks_service_group_desired_size
      min_size          = var.eks_service_group_min_size
      max_size          = var.eks_service_group_max_size

      # for node affinity
      labels = {
        node-group = "service"
      }

      iam_role_additional_policies = {
        # Required by Karpenter
        AmazonSSMManagedInstanceCore = "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"

        # Required by EBS CSI Add-on
        AmazonEBSCSIDriverPolicy = data.aws_iam_policy.AmazonEBSCSIDriverPolicy.arn
      }

      instance_types = ["${var.eks_service_group_instance_type}"]
      tags = merge(
        local.tags,
        { Name = "eks-${var.shared_resource_identifier}" }
      )
    }

  }
}

#------------------------------------------------------------------------------
#                           SUPPORTING RESOURCES
#------------------------------------------------------------------------------
data "template_file" "eks-console-full-access" {
  template = file("${path.module}/yml/eks-console-full-access.yaml")
  vars     = {}
}

# add an AWS IAM Role definition providing AWS console access to
# AWS EKS cluster instances.
resource "kubectl_manifest" "eks-console-full-access" {
  yaml_body = data.template_file.eks-console-full-access.rendered
}

# to enable shell access to nodes from kubectl
resource "aws_security_group" "worker_group_mgmt" {
  name_prefix = "${var.name}-eks_hosting_group_mgmt"
  description = "openedx-k8s-harmony: Ingress CLB worker group management"
  vpc_id      = data.aws_vpc.reference.id

  ingress {
    description = "openedx-k8s-harmony: Ingress CLB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }

  tags = local.tags
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "${var.name}-eks_all_worker_management"
  description = "openedx-k8s-harmony: Ingress CLB worker management"
  vpc_id      = data.aws_vpc.reference.id

  ingress {
    description = "openedx-k8s-harmony: Ingress CLB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = local.tags

}
