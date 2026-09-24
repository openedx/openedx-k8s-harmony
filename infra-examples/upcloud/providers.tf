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
      version = ">= 1.21.0, < 2.0.0"
    }
  }
}

provider "upcloud" {
  token = var.upcloud_token
}

provider "mongodbatlas" {
  public_key  = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
}
