# A cluster to test proof of concept on DigitalOcean
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">=2.23"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.15.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.7.1"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

variable "cluster_name" { type = string }
variable "do_token" {
  type = string
  sensitive = true
}

module "k8s_cluster" {
  source = "./k8s-cluster"

  cluster_name          = var.cluster_name
  # max_worker_node_count = var.max_worker_node_count
  # min_worker_node_count = var.min_worker_node_count
  # worker_node_size      = var.worker_node_size
  # region                = var.do_region
  # vpc_uuid              = digitalocean_vpc.main_vpc.id
  # vpc_ip_range          = var.vpc_ip_range
}

# Pre-declare data sources that we can use to get the cluster ID and auth info, once it's created
data "digitalocean_kubernetes_cluster" "cluster" {
  name = var.cluster_name
  # Set the depends_on so that the data source doesn't
  # try to read from a cluster that doesn't exist, causing
  # failures when trying to run a `tofu plan`.
  depends_on = [module.k8s_cluster.cluster_id]
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = data.digitalocean_kubernetes_cluster.cluster.endpoint
  token                  = data.digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = data.digitalocean_kubernetes_cluster.cluster.endpoint
    token                  = data.digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = data.digitalocean_kubernetes_cluster.cluster.endpoint
  token                  = data.digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
  load_config_file       = false
}


# Declare the kubeconfig as an output - access it anytime with "tofu output -raw kubeconfig"
output "kubeconfig" {
  value     = module.k8s_cluster.kubeconfig.raw_config
  sensitive = true
}

resource "digitalocean_project" "project" {
  name        = var.cluster_name
  description = "Testing the use of Helm to provision a cluster for multi-instance tutor deployment"
  purpose     = "Web Application"
  environment = "Production"

  resources = [
    module.k8s_cluster.cluster_urn,
  ]
}
