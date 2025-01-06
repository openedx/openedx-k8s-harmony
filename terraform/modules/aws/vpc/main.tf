terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

resource "random_id" "vpc_suffix" {
  count       = var.vpc_name == "" ? 1 : 0
  byte_length = 8
}

module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "~> 5.17"
  name            = var.vpc_name == "" ? "open-edx-${var.environment}-vpc-${random_id.vpc_suffix[0].dec}" : var.vpc_name
  cidr            = var.cidr
  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  # Your VPC must have DNS hostname and DNS resolution support. Otherwise,
  # your nodes cannot register with your cluster.
  # https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  tags = var.tags
  public_subnet_tags = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags
}
