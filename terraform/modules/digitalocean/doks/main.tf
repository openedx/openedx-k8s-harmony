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

resource "digitalocean_tag" "worker_firewall" {
  name = "fw-${var.cluster_name}-${var.environment}-workers"
}

resource "digitalocean_kubernetes_cluster" "cluster" {
  name         = "${var.cluster_name}-${var.environment}"
  region       = var.region
  version      = var.kubernetes_version
  vpc_uuid     = data.digitalocean_vpc.vpc.id
  auto_upgrade = var.is_auto_upgrade_enabled
  surge_upgrade = var.is_surge_upgrade_enabled

  lifecycle {
    ignore_changes = [
      version,
    ]
  }

  node_pool {
    name       = "${var.cluster_name}-${var.environment}-workers"
    size       = var.worker_node_size
    min_nodes  = var.min_worker_node_count
    max_nodes  = var.max_worker_node_count
    auto_scale = var.is_auto_scaling_enabled
    tags       = [digitalocean_tag.worker_firewall.name]
  }
}


resource "digitalocean_kubernetes_node_pool" "additional_node_pools" {
  for_each = { for pool in var.additional_node_pools : pool.name => pool }

  cluster_id = digitalocean_kubernetes_cluster.cluster.id
  name       = "${var.cluster_name}-${var.environment}-${each.key}-workers"
  size       = each.value.size
  min_nodes  = each.value.min_node_count
  max_nodes  = each.value.max_node_count
  auto_scale = true
  tags       = [digitalocean_tag.worker_firewall.name]
  labels     = each.value.labels
}
