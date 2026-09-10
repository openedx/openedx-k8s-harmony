terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.62"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.17"
    }
  }
}

locals {
  region = upper(replace(var.region, "-", "_"))
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

resource "mongodbatlas_advanced_cluster" "cluster" {
  depends_on = [mongodbatlas_network_container.cluster_network_container]

  project_id                  = var.mongodbatlas_project_id
  name                        = "${var.database_cluster_name}-${var.environment}"
  mongo_db_major_version      = var.database_cluster_version
  cluster_type                = var.database_cluster_type
  backup_enabled              = true
  use_effective_fields        = var.is_database_autoscaling_compute_enabled ? true : null
  encryption_at_rest_provider = var.is_database_storage_encrypted ? "AWS" : "NONE"

  replication_specs = [
    for _ in range(var.database_shards) : {
      region_configs = [{
        priority      = 7
        provider_name = "AWS"
        region_name   = local.region

        electable_specs = {
          instance_size   = var.database_cluster_instance_size
          node_count      = var.database_electable_nodes
          disk_iops       = var.database_storage_ipos
          ebs_volume_type = var.database_storage_type
          disk_size_gb    = var.is_database_autoscaling_disk_gb_enabled ? null : var.database_storage_size
        }

        analytics_specs = var.database_analytics_nodes != null && var.database_analytics_nodes > 0 ? {
          instance_size   = var.database_cluster_instance_size
          node_count      = var.database_analytics_nodes
          disk_iops       = var.database_storage_ipos
          ebs_volume_type = var.database_storage_type
          disk_size_gb    = var.is_database_autoscaling_disk_gb_enabled ? null : var.database_storage_size
        } : null

        read_only_specs = var.database_read_only_nodes != null && var.database_read_only_nodes > 0 ? {
          instance_size   = var.database_cluster_instance_size
          node_count      = var.database_read_only_nodes
          disk_iops       = var.database_storage_ipos
          ebs_volume_type = var.database_storage_type
          disk_size_gb    = var.is_database_autoscaling_disk_gb_enabled ? null : var.database_storage_size
        } : null

        auto_scaling = merge(
          {
            disk_gb_enabled            = var.is_database_autoscaling_disk_gb_enabled
            compute_enabled            = var.is_database_autoscaling_compute_enabled
            compute_scale_down_enabled = var.is_database_autoscaling_compute_enabled
          },
          var.is_database_autoscaling_compute_enabled ? {
            compute_min_instance_size = var.database_autoscaling_min_instances
            compute_max_instance_size = var.database_autoscaling_max_instances
          } : {}
        )
      }]
    }
  ]
}

resource "mongodbatlas_cloud_backup_schedule" "backup_schedule" {
  project_id   = mongodbatlas_advanced_cluster.cluster.project_id
  cluster_name = mongodbatlas_advanced_cluster.cluster.name

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

# Add peering connection to private routing tables so EKS nodes can reach Atlas
resource "aws_route" "peeraccess" {
  count = length(var.private_route_table_ids)

  route_table_id            = var.private_route_table_ids[count.index]
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

  scopes {
    type = "CLUSTER"
    name = mongodbatlas_advanced_cluster.cluster.name
  }
}
