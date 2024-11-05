variable "aws_region" {
  description = "The AWS Region in which to deploy the resources"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
  default     = []
}
variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
  default     = []
}
variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = []
}
variable "vpc_name" {
  description = "The VPC name"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Single NAT Gateway"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "One NAT gateway per AZ"
  type        = bool
  default     = true
}

variable "instance_types" {
  type        = list(string)
  description = "EC2 Instance type for the nodes"
}
variable "cluster_version" {
  default     = "1.29"
  type        = string
  description = "Kubernetes version"
}
variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}
variable "desired_size" {
  default     = 2
  type        = number
  description = "Desired node count"
}
variable "disk_size" {
  default     = 40
  type        = number
  description = "Node disk size"
}
variable "key_name" {
  type        = string
  description = "Name of the SSH Key Pair"
}
variable "max_size" {
  default     = 3
  type        = number
  description = "Maximum node count"
}
variable "min_size" {
  default     = 1
  type        = number
  description = "Minimum node count"
}
variable "extra_ssh_cidrs" {
  default     = []
  type        = list(string)
  description = "List of additional IP blocks with ssh access"
}
variable "registry_credentials" {
  type        = string
  description = "Image registry credentials to be added to the node"
}
variable "node_groups_tags" {
  description = "A map of tags to add to all node group resources"
  type        = map(string)
  default     = {}
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
# Variables for migration from 17.x.x to 18.x.x - Cluster
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
variable "node_group_subnets" {
  description = "List of subnets where nodes groups are deployed. Normally these are private and the same as EKS"
  type        = list(string)
  default     = null
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
variable "node_group_name" {
  description = "Name of the node group"
  type        = string
  default     = "ubuntu_worker"
}
variable "capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: `ON_DEMAND`, `SPOT`"
  type        = string
  default     = "ON_DEMAND"
}
variable "post_bootstrap_user_data" {
  type        = string
  default     = null
  description = "Allow to add post bootstrap user data"
}
