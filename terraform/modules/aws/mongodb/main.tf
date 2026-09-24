terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
  }
}

locals {
  region = upper(replace(var.region, "-", "_"))
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

# Network container to define the MongoDB Atlas CIDR block
resource "mongodbatlas_network_container" "cluster_network_container" {
  project_id       = var.mongodbatlas_project_id
  atlas_cidr_block = var.mongodbatlas_cidr_block
  provider_name    = "AWS"
  region_name      = local.region
}

module "cluster" {
  source = "../../mongodb"

  environment                             = var.environment
  mongodbatlas_project_id                 = var.mongodbatlas_project_id
  database_cluster_name                   = var.database_cluster_name
  atlas_region_name                       = local.region
  ip_access_cidrs                         = [data.aws_vpc.main.cidr_block]
  database_cluster_version                = var.database_cluster_version
  database_cluster_type                   = var.database_cluster_type
  database_cluster_instance_size          = var.database_cluster_instance_size
  database_shards                         = var.database_shards
  database_electable_nodes                = var.database_electable_nodes
  database_read_only_nodes                = var.database_read_only_nodes
  database_analytics_nodes                = var.database_analytics_nodes
  database_storage_size                   = var.database_storage_size
  database_storage_ipos                   = var.database_storage_ipos
  database_storage_type                   = var.database_storage_type
  database_autoscaling_min_instances      = var.database_autoscaling_min_instances
  database_autoscaling_max_instances      = var.database_autoscaling_max_instances
  is_database_autoscaling_compute_enabled = var.is_database_autoscaling_compute_enabled
  is_database_autoscaling_disk_gb_enabled = var.is_database_autoscaling_disk_gb_enabled
  database_backup_retention_period        = var.database_backup_retention_period
  is_database_storage_encrypted           = var.is_database_storage_encrypted
  database_users                          = var.database_users

  depends_on = [mongodbatlas_network_container.cluster_network_container]
}

# Peering between MongoDB Atlas and VPC
resource "mongodbatlas_network_peering" "cluster_network_peering" {
  project_id             = var.mongodbatlas_project_id
  container_id           = mongodbatlas_network_container.cluster_network_container.id
  accepter_region_name   = var.region
  provider_name          = "AWS"
  route_table_cidr_block = data.aws_vpc.main.cidr_block
  vpc_id                 = var.vpc_id
  aws_account_id         = var.aws_account_id
}

# Auto accept peering connection request
resource "aws_vpc_peering_connection_accepter" "accept_mongo_peer" {
  vpc_peering_connection_id = mongodbatlas_network_peering.cluster_network_peering.connection_id
  auto_accept               = true
}

# Add peering connection to private routing table
resource "aws_route" "peeraccess" {
  route_table_id            = data.aws_vpc.main.main_route_table_id
  destination_cidr_block    = var.mongodbatlas_cidr_block
  vpc_peering_connection_id = mongodbatlas_network_peering.cluster_network_peering.connection_id
  depends_on = [
    aws_vpc_peering_connection_accepter.accept_mongo_peer
  ]
}
