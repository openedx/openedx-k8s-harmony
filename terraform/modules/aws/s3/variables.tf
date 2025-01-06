variable "environment" {
  type        = string
  description = "The AWS project environment. (for example: production, staging, development, etc.)"
}

variable "bucket_prefix" {
  type        = string
  description = "The prefix for the AWS s3 bucket for easier identification."
}

variable "allowed_cors_origins" {
  type        = list(string)
  default     = ["*"]
  description = "Lists the CORS origins to allow CORS requests from."
}

variable "is_public" {
  type        = bool
  default     = false
  description = "Determines whether the AWS s3 bucket's root object is publicly available or not."
}

variable "is_force_destroy_enabled" {
  type        = bool
  default     = true
  description = "Determines if the AWS s3 bucket is force-destroyed or not upon deletion."
}

variable "is_versioning_enabled" {
  type        = bool
  default     = true
  description = "Determines if versioning is allowed on the AWS s3 bucket or not."
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
