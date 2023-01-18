terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">=2.23"
    }
  }
}

variable "cluster_name" { type = string }
variable "do_region" {
  type    = string
  default = "tor1"
}

data "digitalocean_kubernetes_versions" "available_versions" {}

resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = var.cluster_name
  region  = var.do_region
  version = data.digitalocean_kubernetes_versions.available_versions.latest_version
  #vpc_uuid     = var.vpc_uuid
  auto_upgrade = true
  # "Surge upgrade makes cluster upgrades fast and reliable by bringing up new nodes before destroying the outdated nodes."
  surge_upgrade = true

  node_pool {
    name       = "${var.cluster_name}-nodes"
    size       = "s-4vcpu-8gb"
    # At this size, at least 3 nodes are recommended to run 2 Open edX instances using the default Tutor images, because
    # resources like MySQL/MongoDB are not shared.
    min_nodes  = 3
    max_nodes  = 4
    auto_scale = true
  }
}

resource "local_sensitive_file" "kubeconfig" {
  filename        = "${path.root}/kubeconfig"
  content         = digitalocean_kubernetes_cluster.cluster.kube_config[0].raw_config
  file_permission = "0400"
}

output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.cluster.kube_config[0]
  sensitive = true
}

output "cluster_urn" {
  value = digitalocean_kubernetes_cluster.cluster.urn
}

output "cluster_id" {
  value = digitalocean_kubernetes_cluster.cluster.id
}
