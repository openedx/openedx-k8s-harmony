variable "region" {
  type        = string
  description = "DigitalOcean region to create the resources in."
  validation {
    condition = contains([
      "ams3",
      "blr1",
      "fra1",
      "lon1",
      "nyc3",
      "sfo2",
      "sfo3",
      "sgp1",
      "syd1",
      "tor1",
    ], var.region)
    error_message = "The DigitalOcean region must be in the acceptable region list."
  }
}

variable "environment" {
  type        = string
  description = "The DigitalOcean project environment. (for example: production, staging, development, etc.)"
}

variable "bucket_prefix" {
  type = string
  description = "The prefix for the DigitalOcean spaces bucket for easier identification."
}

variable "allowed_cors_origins" {
  type    = list(string)
  default = ["*"]
  description = "Lists the CORS origins to allow CORS requests from."
}

variable "is_public" {
  type    = bool
  default = false
  description = "Determines whether the DigitalOcean spaces bucket's root object is publicly available or not."
}

variable "is_force_destroy_enabled" {
  type    = bool
  default = true
  description = "Determines if the DigitalOcean spaces bucket is force-destroyed or not upon deletion."
}

variable "is_versioning_enabled" {
  type    = bool
  default = true
  description = "Determines if versioning is allowed on the DigitalOcean spaces bucket or not."
}

