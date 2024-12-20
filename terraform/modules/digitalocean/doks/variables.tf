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

variable "cluster_name" {
  type = string
  description = "The name of the Kubernetes cluster."
}

variable "kubernetes_version" {
  type = string
  description = "The supported Kubernetes version to install for the cluster."
}

variable "additional_node_pools" {
  type = list(object({
    name           = string
    size           = string
    min_node_count = number
    max_node_count = number
    labels         = optional(map(any))
  }))
  default     = []
  description = "Additional node pools attached to the cluster."
}

variable "worker_node_size" {
  type        = string
  default     = "s-2vcpu-4gb"
  description = "Kubernetes worker node size."
}

variable "min_worker_node_count" {
  type        = number
  default     = 3
  description = "Minimum number of running Kubernetes worker nodes."
}

variable "max_worker_node_count" {
  type        = number
  default     = 5
  description = "Maximum number of running Kubernetes worker nodes."
}

variable "vpc_id" {
  type = string
  description = "ID of the VPC to use for the Kubernetes cluster."
}

variable "is_auto_upgrade_enabled" {
  type = bool
  default = true
  description = "Whether auto upgrade is enabled for the cluster or not."
}

variable "is_surge_upgrade_enabled" {
  type = bool
  default = true
  description = "Whether surge upgrade is enabled for the cluster or not."
}

variable "is_auto_scaling_enabled" {
  type = bool
  default = true
  description = "Whether auto scaling is enabled for the cluster or not."
}
