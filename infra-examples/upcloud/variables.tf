variable "zone" {
  type        = string
  description = "UpCloud zone to create the resources in."

  validation {
    condition = contains([
      "au-syd1",
      "de-fra1",
      "dk-cph1",
      "es-mad1",
      "fi-hel1",
      "fi-hel2",
      "nl-ams1",
      "pl-waw1",
      "no-svg1",
      "se-sto1",
      "sg-sin1",
      "uk-lon1",
      "us-chi1",
      "us-nyc1",
      "us-sjo1",
    ], var.zone)
    error_message = "The UpCloud zone must be in the acceptable zone list."
  }
}

variable "object_storage_region" {
  type        = string
  description = "Managed Object Storage region that contains var.zone, for example europe-1 for de-fra1."
}

variable "environment" {
  type        = string
  description = "The UpCloud project environment. (for example: production, staging, development, etc.)"
}

variable "kubernetes_cluster_name" {
  type        = string
  description = "Name of the Kubernetes cluster to create."
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes minor version. List supported versions with `upctl kubernetes versions`."
}

variable "bucket_prefix" {
  type        = string
  description = "Prefix for the object storage bucket name."
}

variable "upcloud_token" {
  type        = string
  default     = null
  sensitive   = true
  description = "UpCloud API Token. Null uses the UPCLOUD_TOKEN environment variable."
}

variable "mongodbatlas_project_id" {
  type        = string
  description = "The ID of the MongoDB Atlas project that hosts the cluster."
}

variable "atlas_region_name" {
  type        = string
  description = "Atlas region for the cluster, for example EU_CENTRAL_1 when the UpCloud zone is de-fra1."
}

variable "mongodbatlas_public_key" {
  type        = string
  default     = null
  sensitive   = true
  description = "MongoDB Atlas public API key. Null uses the MONGODB_ATLAS_PUBLIC_KEY environment variable."
}

variable "mongodbatlas_private_key" {
  type        = string
  default     = null
  sensitive   = true
  description = "MongoDB Atlas private API key. Null uses the MONGODB_ATLAS_PRIVATE_KEY environment variable."
}
