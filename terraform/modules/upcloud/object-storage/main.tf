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

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  suffix       = random_id.suffix.hex
  service_name = substr(lower("openedx-${var.environment}-${local.suffix}"), 0, 63)
  bucket_name  = substr(lower("${var.bucket_prefix}-${var.environment}-${local.suffix}"), 0, 63)
}

resource "upcloud_managed_object_storage" "this" {
  name              = local.service_name
  region            = var.region
  configured_status = "started"
  labels            = var.labels

  # Attaching a private network replaces the default public endpoint unless a
  # public network block is set as well.
  dynamic "network" {
    for_each = var.network_id != "" ? [1] : []

    content {
      family = "IPv4"
      name   = "public"
      type   = "public"
    }
  }

  dynamic "network" {
    for_each = var.network_id != "" ? [1] : []

    content {
      family = "IPv4"
      name   = "private"
      type   = "private"
      uuid   = var.network_id
    }
  }
}

resource "upcloud_managed_object_storage_bucket" "this" {
  service_uuid = upcloud_managed_object_storage.this.id
  name         = local.bucket_name
}

resource "upcloud_managed_object_storage_user" "this" {
  username     = "openedx"
  service_uuid = upcloud_managed_object_storage.this.id
}

resource "upcloud_managed_object_storage_user_access_key" "this" {
  username     = upcloud_managed_object_storage_user.this.username
  service_uuid = upcloud_managed_object_storage.this.id
  status       = "Active"
}
