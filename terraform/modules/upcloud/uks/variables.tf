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
  description = "Number of nodes in the default worker group. UKS node groups use a fixed count, not min/max autoscaling."

  validation {
    condition     = var.worker_node_count > 0
    error_message = "Worker node count must be at least 1."
  }
}

variable "additional_node_pools" {
  type = list(object({
    name       = string
    plan       = string
    node_count = number
    labels     = optional(map(string), {})
  }))
  default     = []
  description = "Extra node groups. Each name must be unique in the cluster and must not be \"workers\"."
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels applied to the cluster and node groups."
}
