#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: mar-2022
#
# usage: create a VPC to contain all Open edX backend resources.
#        this VPC is configured to generally use all AWS defaults.
#        Thus, you should get the same configuration here that you'd
#        get by creating a new VPC from the AWS Console.
#
#        There are a LOT of options in this module.
#        see https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#------------------------------------------------------------------------------
locals {
  azs = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]

  # a bit of foreshadowing:
  # AWS EKS uses tags for identifying resources which it interacts.
  # here we are tagging the public and private subnets with specially-named tags
  # that EKS uses to know where its public and internal load balancers should be placed.
  #
  # these tags are required, regardless of whether we're using EKS with EC2 worker nodes
  # or with a Fargate Compute Cluster.
  public_subnet_tags = {
    "Type"                              = "public"
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/elb"            = "1"
  }

  private_subnet_tags = {
    "Type"                              = "private"
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = "1"
    "karpenter.sh/discovery"            = var.name
  }

  tags = {
    "Name"                       = var.name
    "openedx-k8s-harmony/name"   = var.name
    "openedx-k8s-harmony/region" = var.aws_region
    "openedx-k8s-harmony/tofu"   = "true"
  }


}

module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 4.0"
  create_vpc             = true
  azs                    = local.azs
  public_subnet_tags     = local.public_subnet_tags
  private_subnet_tags    = local.private_subnet_tags
  tags                   = local.tags
  name                   = var.name
  cidr                   = var.cidr
  public_subnets         = var.public_subnets
  private_subnets        = var.private_subnets
  database_subnets       = var.database_subnets
  elasticache_subnets    = var.elasticache_subnets
  enable_ipv6            = var.enable_ipv6
  enable_dns_hostnames   = var.enable_dns_hostnames
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
}
