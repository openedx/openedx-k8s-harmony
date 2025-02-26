variable "environment" {
  type        = string
  description = "The AWS project environment. (for example: production, staging, development, etc.)"
}

variable "cluster_name" {
  type        = string
  description = "The name of the Kubernetes cluster."
}

variable "cluster_security_group_use_name_prefix" {
  description = "Determinate if it is necessary to create an security group prefix for the cluster"
  type        = bool
  default     = true
}

variable "cluster_security_group_name" {
  description = "Cluster security group name"
  type        = string
  default     = null
}

variable "cluster_security_group_description" {
  description = "Cluster security group description"
  type        = string
  default     = "EKS cluster security group"
}

variable "cluster_tags" {
  description = "A map of tags to add to the cluster"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "kubernetes_version" {
  type        = string
  description = "The supported Kubernetes version to install for the cluster."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to use for the Kubernetes cluster."
}

variable "private_subnets" {
  type        = list(string)
  default     = ["10.10.0.0/21", "10.10.8.0/21"]
  description = "List of private subnets"
}

variable "worker_node_instance_types" {
  type        = list(string)
  description = "EC2 Instance type for the nodes"
}

variable "worker_node_disk_size" {
  default     = 40
  type        = number
  description = "Node disk size"
}

variable "worker_node_count" {
  default     = 2
  type        = number
  description = "Desired autoscaling node count"
}

variable "max_worker_node_count" {
  default     = 3
  type        = number
  description = "Maximum node count in the autoscaling group"
}

variable "min_worker_node_count" {
  default     = 1
  type        = number
  description = "Minimum node count in the autoscaling group"
}

variable "worker_node_ssh_key_name" {
  type        = string
  description = "Name of the SSH Key Pair used for the worker nodes"
}

variable "worker_node_extra_ssh_cidrs" {
  type        = list(string)
  description = "List of additional IP blocks with ssh access to the worker nodes"
  default     = []
}

variable "worker_node_groups_tags" {
  description = "A map of tags to add to all node group resources"
  type        = map(string)
  default     = {}
}

variable "worker_node_group_name" {
  description = "Name of the node group"
  type        = string
  default     = "ubuntu_worker"
}

variable "worker_node_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: `ON_DEMAND`, `SPOT`"
  type        = string
  default     = "ON_DEMAND"
}

variable "registry_credentials" {
  type        = string
  description = "Image registry credentials to be added to the node"
}

variable "enable_cluster_autoscaler" {
  description = "Determines whether to prepare the cluster to use cluster autoscaler"
  type        = bool
  default     = false
}

variable "ubuntu_version" {
  description = "Ubuntu version to use (e.g. focal-20.04) when no ami_id is provided"
  type        = string
  default     = "jammy-22.04"
  validation { # Validates wheter the value is in format str-num.num
    condition     = can(regex("^([a-z]+)-([0-9]+\\.[0-9]+)$", var.ubuntu_version))
    error_message = "The value must be in format str-num.num (e.g. focal-20.04)."
  }
}

variable "ami_id" {
  description = "EKS nodes AMI ID"
  type        = string
  default     = ""
}

variable "iam_role_use_name_prefix" {
  description = "Determinate if it is necessary to create an iam role prefix for the cluster"
  type        = bool
  default     = true
}

variable "iam_role_name" {
  description = "Cluster IAM role name"
  type        = string
  default     = null
}

variable "post_bootstrap_user_data" {
  type        = string
  default     = null
  description = "Allow to add post bootstrap user data"
}
