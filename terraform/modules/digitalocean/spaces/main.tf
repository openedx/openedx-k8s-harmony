terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
    }

    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "digitalocean_spaces_bucket" "spaces_bucket" {
  name          = "${var.bucket_prefix}-${var.environment}-${random_id.bucket_suffix.dec}"
  region        = var.region
  acl           = "private"
  force_destroy = var.is_force_destroy_enabled

  versioning {
    enabled = var.is_versioning_enabled
  }

  lifecycle_rule {
    enabled = true

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_expiration {
      days = 30
    }
  }
}

resource "digitalocean_spaces_bucket_cors_configuration" "spaces_bucket_policy" {
  bucket = digitalocean_spaces_bucket.spaces_bucket.id
  region = var.region

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = var.allowed_cors_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "digitalocean_spaces_bucket_policy" "public_root_object_policy" {
  count  = var.is_public ? 1 : 0

  bucket = digitalocean_spaces_bucket.spaces_bucket.name
  region = var.region

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ForumUploads",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${digitalocean_spaces_bucket.spaces_bucket.name}/*",
        ]
      }
    ]
  })
}
