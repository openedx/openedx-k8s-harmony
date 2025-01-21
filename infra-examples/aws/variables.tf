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
  description = "Name of the DigitalOcean Kubernetes cluster to create."
}

variable "worker_node_ssh_key_name" {
  type        = string
  description = "Name of the SSH Key Pair used for the worker nodes"
}

variable "mongodbatlas_project_id" {
  type        = string
  description = "The ID of the MongoDB Atlas project"
}

variable "mongodbatlas_cidr_block" {
  type        = string
  description = "The CIDR block in MongoDB Atlas"
}
