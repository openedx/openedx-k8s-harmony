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

resource "random_id" "network_suffix" {
  count       = var.network_name == "" ? 1 : 0
  byte_length = 4
}

locals {
  name = var.network_name == "" ? "open-edx-${var.environment}-${random_id.network_suffix[0].hex}" : var.network_name
}

resource "upcloud_router" "this" {
  name   = "${local.name}-router"
  labels = var.labels

  # The NAT gateway adds a service route. Without this, later applies try to
  # delete that route.
  lifecycle {
    ignore_changes = [static_route]
  }
}

resource "upcloud_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  name     = "${local.name}-nat"
  zone     = var.zone
  features = ["nat"]
  plan     = var.gateway_plan
  labels   = var.labels

  router {
    id = upcloud_router.this.id
  }

  address {
    name = "nat"
  }
}

resource "upcloud_network" "this" {
  name   = local.name
  zone   = var.zone
  router = upcloud_router.this.id
  labels = var.labels

  # Private UKS node groups need the gateway to exist before nodes boot.
  depends_on = [upcloud_gateway.this]

  ip_network {
    address            = var.ip_network_address
    dhcp               = true
    dhcp_default_route = var.enable_nat_gateway
    family             = "IPv4"
  }
}
