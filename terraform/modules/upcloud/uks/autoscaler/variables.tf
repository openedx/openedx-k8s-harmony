variable "cluster_id" {
  type        = string
  description = "UUID of the UKS cluster. Passed to the autoscaler as UPCLOUD_CLUSTER_ID."
}

variable "upcloud_token" {
  type        = string
  sensitive   = true
  description = "UpCloud API token stored in the upcloud-autoscaler Secret. Prefer a token that can manage only this cluster."

  validation {
    condition     = length(var.upcloud_token) > 0
    error_message = "Cluster Autoscaler requires an UpCloud API token."
  }
}

variable "node_groups" {
  type = list(object({
    name           = string
    min_node_count = number
    max_node_count = number
  }))
  description = "Every UKS node group the autoscaler may resize. Each minimum must be at least 1."

  validation {
    condition = length(var.node_groups) > 0 && alltrue([
      for group in var.node_groups :
      group.min_node_count >= 1 && group.max_node_count >= group.min_node_count
    ])
    error_message = "Provide every node group, with a minimum of at least 1 and a maximum at least that large."
  }
}

variable "image" {
  type        = string
  default     = "ghcr.io/upcloudltd/autoscaler:v1.29.5"
  description = "UpCloud fork of Cluster Autoscaler. Do not replace this with the upstream Kubernetes autoscaler image; upstream does not include the UpCloud cloud provider."
}
