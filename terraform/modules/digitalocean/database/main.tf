terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

data "digitalocean_vpc" "vpc" {
  id = var.vpc_id
}

resource "digitalocean_database_cluster" "database_cluster" {
  name                 = substr("${var.kubernetes_cluster_name}-${var.environment}-${var.database_engine}", 0, 30)
  engine               = var.database_engine
  version              = var.database_engine_version
  size                 = var.database_cluster_instance_size
  region               = var.region
  node_count           = var.database_cluster_instances
  private_network_uuid = var.vpc_id
  tags                 = []

  maintenance_window {
    day = var.database_maintenance_window_day
    hour = var.database_maintenance_window_time
  }
}

# DigitalOcean cannot set VPC CIDR blocks for rules, so we have to list the rules
# one by one. Since the rules are dynamic and depends on resources from other modules,
# we dynamically create those rules given as an input for the module. This allows higher
# chance for misconfiguration, but necessary to work with other modules' resources.
resource "digitalocean_database_firewall" "database_cluster_firewall" {
  cluster_id = digitalocean_database_cluster.database_cluster.id

  dynamic "rule" {
    for_each = var.firewall_rules

    content {
      type  = rule.value["type"]
      value = rule.value["value"]
    }
  }
}

resource "digitalocean_database_user" "users" {
  for_each = toset([
    for _, user in var.database_users :
    user.username
  ])

  cluster_id = digitalocean_database_cluster.database_cluster.id
  name       = each.value
}

resource "digitalocean_database_db" "databases" {
  for_each = toset([
    for _, user in var.database_users :
    user.database
  ])

  cluster_id = digitalocean_database_cluster.database_cluster.id
  name       = each.value
}


resource "null_resource" "no_primary_key_patch_database_cluster" {
  triggers = {
    cluster_id = digitalocean_database_cluster.database_cluster.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -X PATCH \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $DO_TOKEN" \
        -d '{"config": {"sql_mode": "ANSI,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,STRICT_ALL_TABLES"}}' \
        "https://api.digitalocean.com/v2/databases/$CLUSTER_ID/config"
    EOT
    environment = {
      DO_TOKEN   = var.access_token
      CLUSTER_ID = digitalocean_database_cluster.database_cluster.id
    }
  }
}
