terraform {
  required_providers {
    upcloud = {
      source = "UpCloudLtd/upcloud"
    }
  }
}

resource "upcloud_kubernetes_cluster" "cluster" {
  name                    = "${var.cluster_name}-${var.environment}"
  network                 = var.network_id
  zone                    = var.zone
  plan                    = var.plan
  version                 = var.kubernetes_version
  private_node_groups     = var.private_node_groups
  control_plane_ip_filter = var.control_plane_ip_filter
  storage_encryption      = var.storage_encryption
  labels                  = var.labels
}

resource "upcloud_kubernetes_node_group" "workers" {
  cluster    = upcloud_kubernetes_cluster.cluster.id
  name       = "workers"
  plan       = var.worker_node_plan
  node_count = var.worker_node_count
  labels     = var.labels
}

resource "upcloud_kubernetes_node_group" "additional" {
  for_each = { for pool in var.additional_node_pools : pool.name => pool }

  cluster    = upcloud_kubernetes_cluster.cluster.id
  name       = each.key
  plan       = each.value.plan
  node_count = each.value.node_count
  labels     = merge(var.labels, each.value.labels)
}

data "upcloud_kubernetes_cluster" "cluster" {
  id = upcloud_kubernetes_cluster.cluster.id
}
