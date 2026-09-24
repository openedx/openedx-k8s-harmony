variable "environment" {
  type        = string
  description = "The UpCloud project environment. (for example: production, staging, development, etc.)"
}

variable "region" {
  type        = string
  description = "Object storage region, for example europe-1. This is not a compute zone. The private network zone must belong to this region."
}

variable "bucket_prefix" {
  type        = string
  description = "Prefix for the bucket name. The module lowercases it and appends the environment and a random suffix."
}

variable "network_id" {
  type        = string
  default     = ""
  description = "Optional private network UUID. When set, the service is attached to that network and to a public endpoint."
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels applied to the Managed Object Storage service."
}
