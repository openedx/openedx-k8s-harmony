terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.0"
    }

    upcloud = {
      source  = "UpCloudLtd/upcloud"
      version = ">= 5.44.1"
    }

    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.17"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.34"
    }
  }
}

provider "upcloud" {
  token = var.upcloud_token
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

provider "kubernetes" {
  host                   = module.kubernetes_cluster.cluster_endpoint
  client_certificate     = module.kubernetes_cluster.client_certificate
  client_key             = module.kubernetes_cluster.client_key
  cluster_ca_certificate = module.kubernetes_cluster.cluster_ca_certificate
}
