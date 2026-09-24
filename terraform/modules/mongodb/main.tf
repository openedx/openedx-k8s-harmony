terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
    }

    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = ">= 1.21.0, < 2.0.0"
    }
  }
}

resource "mongodbatlas_cluster" "cluster" {
  project_id             = var.mongodbatlas_project_id
  name                   = "${var.database_cluster_name}-${var.environment}"
  cluster_type           = var.database_cluster_type
  mongo_db_major_version = var.database_cluster_version

  replication_specs {
    num_shards = var.database_shards

    regions_config {
      priority        = 7
      region_name     = var.atlas_region_name
      electable_nodes = var.database_electable_nodes
      read_only_nodes = var.database_read_only_nodes
      analytics_nodes = var.database_analytics_nodes
    }
  }

  auto_scaling_disk_gb_enabled                    = var.is_database_autoscaling_disk_gb_enabled
  auto_scaling_compute_enabled                    = var.is_database_autoscaling_compute_enabled
  auto_scaling_compute_scale_down_enabled         = var.is_database_autoscaling_compute_enabled
  provider_auto_scaling_compute_min_instance_size = var.database_autoscaling_min_instances
  provider_auto_scaling_compute_max_instance_size = var.database_autoscaling_max_instances

  provider_name               = var.atlas_provider_name
  provider_region_name        = var.atlas_region_name
  disk_size_gb                = var.database_storage_size
  provider_disk_iops          = var.database_storage_ipos
  provider_volume_type        = var.database_storage_type
  cloud_backup                = true
  provider_instance_size_name = var.database_cluster_instance_size
  encryption_at_rest_provider = var.is_database_storage_encrypted ? var.atlas_provider_name : "NONE"
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

resource "mongodbatlas_project_ip_access_list" "access" {
  for_each = { for idx, cidr in var.ip_access_cidrs : tostring(idx) => cidr }

  project_id = var.mongodbatlas_project_id
  cidr_block = each.value
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
    name = mongodbatlas_cluster.cluster.name
  }
}
