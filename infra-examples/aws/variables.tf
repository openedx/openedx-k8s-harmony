variable "region" {
  type        = string
  description = "The AWS Region in which to deploy the resources"
}

variable "environment" {
  type        = string
  description = "The AWS project environment. (for example: production, staging, development, etc.)"
}

variable "docker_registry_credentials" {
  type        = string
  description = "Image registry credentials to be added to the K8s worker nodes"
  default     = ""
}

variable "kubernetes_cluster_name" {
  type        = string
  description = "Name of the Kubernetes cluster to create."
}

variable "worker_node_ssh_key_name" {
  type        = string
  description = "Name of the SSH Key Pair used for the worker nodes"
  default     = null
}

variable "atlas_project_id" {
  type        = string
  description = "The ID of the MongoDB Atlas project."
}

variable "atlas_cidr_block" {
  type        = string
  description = "CIDR block Atlas uses for the peered network container."
}

variable "atlas_public_key" {
  type        = string
  default     = null
  sensitive   = true
  description = "MongoDB Atlas public API key. Null uses the MONGODB_ATLAS_PUBLIC_API_KEY environment variable."
}

variable "atlas_private_key" {
  type        = string
  default     = null
  sensitive   = true
  description = "MongoDB Atlas private API key. Null uses the MONGODB_ATLAS_PRIVATE_API_KEY environment variable."
}
