terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
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

resource "mongodbatlas_cluster" "cluster" {
  depends_on = [mongodbatlas_network_container.cluster_network_container]

  project_id             = var.mongodbatlas_project_id
  name                   = "${var.database_cluster_name}-${var.environment}"
  mongo_db_major_version = var.database_cluster_version

  cluster_type = var.database_cluster_type
  replication_specs {
    num_shards = var.database_shards

    regions_config {
      priority        = 7
      region_name     = local.region
      electable_nodes = var.database_electable_nodes
      read_only_nodes = var.database_read_only_nodes
      analytics_nodes = var.database_analytics_nodes
    }
  }

  # Auto-Scaling Settings
  auto_scaling_disk_gb_enabled                    = var.is_database_autoscaling_disk_gb_enabled
  auto_scaling_compute_enabled                    = var.is_database_autoscaling_compute_enabled
  auto_scaling_compute_scale_down_enabled         = var.is_database_autoscaling_compute_enabled
  provider_auto_scaling_compute_min_instance_size = var.database_autoscaling_min_instances
  provider_auto_scaling_compute_max_instance_size = var.database_autoscaling_max_instances

  # Provider Settings
  provider_name               = "AWS"
  provider_region_name        = local.region
  disk_size_gb                = var.database_storage_size
  provider_disk_iops          = var.database_storage_ipos
  provider_volume_type        = var.database_storage_type
  cloud_backup                = true
  provider_instance_size_name = var.database_cluster_instance_size
  encryption_at_rest_provider = var.is_database_storage_encrypted ? "AWS" : "NONE"
}

resource "mongodbatlas_cloud_backup_schedule" "backup_schedule" {
  project_id   = mongodbatlas_cluster.cluster.project_id
  cluster_name = mongodbatlas_cluster.cluster.name

  restore_window_days = var.database_backup_retention_period

  policy_item_daily {
    frequency_interval = 1
    retention_unit     = "days"
    retention_value    = var.database_backup_retention_period
  }
}


# Add the vpc CIDR block to the access list
resource "mongodbatlas_project_ip_access_list" "cluster_access_list" {
  project_id = var.mongodbatlas_project_id
  cidr_block = data.aws_vpc.main.cidr_block
}

# Network container to define the MongoDB Atlas CIDR block
resource "mongodbatlas_network_container" "cluster_network_container" {
  project_id       = var.mongodbatlas_project_id
  atlas_cidr_block = var.mongodbatlas_cidr_block
  provider_name    = "AWS"
  region_name      = local.region
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

resource "random_password" "user_passwords" {
  for_each = toset([
    for _, user in var.database_users :
    user.username
  ])

  length           = 16
  special          = true
  override_special = "$()-_[]{}<>"
}

resource "mongodbatlas_database_user" "users" {
  for_each = {
    for _, user in var.database_users :
    user.username => user
  }

  project_id         = var.mongodbatlas_project_id
  auth_database_name = "admin"

  username = each.key
  password = random_password.user_passwords[each.key].result

  roles {
    role_name     = "readAnyDatabase"
    database_name = "admin"
  }

  roles {
    role_name     = "readWrite"
    database_name = each.value.database
  }

  roles {
    role_name     = "readWrite"
    database_name = each.value.forum_database
  }

  scopes {
    type = "CLUSTER"
    name = mongodbatlas_cluster.cluster.name
  }
}
