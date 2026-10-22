locals {
  kubernetes_version    = "1.36"
  cluster_name          = "${var.kubernetes_cluster_name}-${var.environment}"
  atlas_region_name     = upper(replace(var.region, "-", "_"))
  atlas_ip_access_cidrs = [module.main_vpc.vpc_cidr_block]
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

module "main_vpc" {
  source = "../../terraform/modules/aws/vpc"

  environment        = var.environment
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)

  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
  ]

  public_subnet_tags = {
    "Tier"                   = "Public"
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "Tier"                            = "Private"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

module "kubernetes_cluster" {
  source = "../../terraform/modules/aws/eks"

  environment = var.environment
  vpc_id      = module.main_vpc.vpc_id
  subnet_ids  = module.main_vpc.private_subnets

  cluster_name         = var.kubernetes_cluster_name
  kubernetes_version   = local.kubernetes_version
  ubuntu_version       = "resolute-26.04"
  registry_credentials = var.docker_registry_credentials

  worker_node_ssh_key_name   = var.worker_node_ssh_key_name
  worker_node_instance_types = ["m6i.large"]
}

module "bucket" {
  source = "../../terraform/modules/aws/s3"

  environment   = var.environment
  bucket_prefix = "my-institute"
}

module "mysql_database" {
  source     = "../../terraform/modules/aws/rds"
  depends_on = [module.main_vpc]

  environment = var.environment
  vpc_id      = module.main_vpc.vpc_id
  subnet_ids  = module.main_vpc.private_subnets

  database_cluster_name = "${module.kubernetes_cluster.cluster_name}-mysql"
}

module "atlas_network" {
  source = "../../terraform/modules/aws/atlas-network"

  region                  = var.region
  aws_account_id          = data.aws_caller_identity.current.account_id
  atlas_project_id        = var.atlas_project_id
  atlas_region_name       = local.atlas_region_name
  atlas_cidr_block        = var.atlas_cidr_block
  vpc_id                  = module.main_vpc.vpc_id
  private_route_table_ids = module.main_vpc.private_route_table_ids
}

module "mongodb_database" {
  source = "../../terraform/modules/mongodb"

  depends_on = [module.atlas_network]

  environment           = var.environment
  atlas_project_id      = var.atlas_project_id
  database_cluster_name = "${var.kubernetes_cluster_name}-mongodb"
  atlas_region_name     = local.atlas_region_name
  atlas_provider_name   = "AWS"
  ip_access_cidrs       = local.atlas_ip_access_cidrs
}
