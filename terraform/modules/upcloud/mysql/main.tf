terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
    }

    upcloud = {
      source = "UpCloudLtd/upcloud"
    }
  }
}

resource "random_password" "database_user" {
  for_each = var.database_users

  length           = 32
  special          = true
  override_special = "!#%&*()-_=+[]{}<>:?"
}

locals {
  labels = merge(
    { environment = var.environment },
    var.labels,
  )
}

resource "upcloud_managed_database_mysql" "this" {
  name                    = var.database_cluster_name
  title                   = var.database_cluster_name
  plan                    = var.plan
  zone                    = var.zone
  labels                  = local.labels
  maintenance_window_dow  = var.maintenance_window_dow
  maintenance_window_time = var.maintenance_window_time

  network {
    family = "IPv4"
    name   = "private"
    type   = "private"
    uuid   = var.network_id
  }

  # Open edX still needs a non-default sql_mode. DigitalOcean applies the same
  # mode out of band because of openedx/edx-platform#30709. Primary keys are
  # not required, because Open edX migrations create tables without them.
  properties {
    public_access           = false
    ip_filter               = [var.network_cidr]
    sql_mode                = "ANSI,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,STRICT_ALL_TABLES"
    sql_require_primary_key = false
  }
}

resource "upcloud_managed_database_logical_database" "databases" {
  for_each = toset([for user in var.database_users : user.database])

  service = upcloud_managed_database_mysql.this.id
  name    = each.value
}

resource "upcloud_managed_database_user" "users" {
  for_each = var.database_users

  service  = upcloud_managed_database_mysql.this.id
  username = each.value.username
  password = random_password.database_user[each.key].result

  depends_on = [upcloud_managed_database_logical_database.databases]
}
