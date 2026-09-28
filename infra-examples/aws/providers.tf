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

provider "aws" {
  region = var.region
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}
