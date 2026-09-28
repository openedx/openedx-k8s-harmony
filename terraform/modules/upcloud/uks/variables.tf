variable "environment" {
  type        = string
  description = "The UpCloud project environment. (for example: production, staging, development, etc.)"
}

variable "zone" {
  type        = string
  description = "UpCloud zone for the cluster. Must match the private network zone."
}

variable "network_id" {
  type        = string
  description = "UUID of the private network the cluster runs in."
}

variable "cluster_name" {
  type        = string
  description = "Cluster name prefix. The module appends the environment, and the result must be unique in the account."
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes minor version, for example 1.32. List supported versions with `upctl kubernetes versions`."
}

variable "plan" {
  type        = string
  default     = "dev-md"
  description = "UKS control plane plan. List plans with `upctl kubernetes plans`. Use a production plan for real clusters."
}

variable "private_node_groups" {
  type        = bool
  default     = true
  description = "Place node groups on the private network. Requires a NAT gateway on that network."
}

variable "control_plane_ip_filter" {
  type        = set(string)
  default     = ["0.0.0.0/0"]
  description = "CIDRs allowed to reach the cluster API. Does not restrict node groups or exposed services."
}

variable "storage_encryption" {
  type        = string
  default     = null
  description = "Default node storage encryption. Valid values are data-at-rest and none. Null uses the provider default."

  validation {
    condition     = var.storage_encryption == null || contains(["data-at-rest", "none"], var.storage_encryption)
    error_message = "Storage encryption must be data-at-rest or none."
  }
}

variable "worker_node_plan" {
  type        = string
  default     = "2xCPU-4GB"
  description = "Server plan for the default worker node group. List plans with `upctl server plans`."
}

variable "worker_node_count" {
  type        = number
  default     = 3
  description = "Initial number of nodes in the default worker group. Cluster Autoscaler may change this later between worker_node_min_count and worker_node_max_count."

  validation {
    condition     = var.worker_node_count >= var.worker_node_min_count && var.worker_node_count <= var.worker_node_max_count
    error_message = "Initial worker node count must sit between worker_node_min_count and worker_node_max_count."
  }
}

variable "worker_node_min_count" {
  type        = number
  default     = 1
  description = "Minimum size Cluster Autoscaler may apply to the workers group. Must be at least 1."

  validation {
    condition     = var.worker_node_min_count >= 1
    error_message = "Worker node minimum must be at least 1. A zero-sized group stops the UpCloud autoscaler."
  }
}

variable "worker_node_max_count" {
  type        = number
  default     = 5
  description = "Maximum size Cluster Autoscaler may apply to the workers group."

  validation {
    condition     = var.worker_node_max_count >= var.worker_node_min_count
    error_message = "Worker node maximum must be at least worker_node_min_count."
  }
}

variable "additional_node_pools" {
  type = list(object({
    name           = string
    plan           = string
    node_count     = number
    min_node_count = optional(number, 1)
    max_node_count = optional(number, 5)
    labels         = optional(map(string), {})
  }))
  default     = []
  description = "Extra node groups. Each name must be unique in the cluster and must not be \"workers\". min_node_count and max_node_count are the autoscaler range."
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels applied to the cluster and node groups."
}
