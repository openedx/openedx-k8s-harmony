terraform {
  required_version = ">= 1.5.7"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.100"
    }
  }
}

resource "random_id" "vpc_suffix" {
  count       = var.vpc_name == "" ? 1 : 0
  byte_length = 8
}

resource "digitalocean_vpc" "vpc" {
  name     = var.vpc_name == "" ? "open-edx-${var.environment}-vpc-${random_id.vpc_suffix[0].dec}" : var.vpc_name
  region   = var.region
  ip_range = var.vpc_ip_range

  timeouts {
    delete = "3m"
  }
}
