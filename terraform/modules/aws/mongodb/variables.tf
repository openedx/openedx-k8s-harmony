variable "region" {
  type        = string
  description = "The AWS Region in which to deploy the resources"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
}

variable "environment" {
  type        = string
  description = "The AWS project environment. (for example: production, staging, development, etc.)"
}

variable "mongodbatlas_project_id" {
  type        = string
  description = "The ID of the MongoDB Atlas project"
}

variable "mongodbatlas_cidr_block" {
  type        = string
  description = "The CIDR block in MongoDB Atlas"
}

variable "database_cluster_name" {
  type        = string
  description = "The name of the MongoDB cluster"
}

variable "database_cluster_version" {
  type        = string
  description = "The version of the MongoDB cluster"
  default     = "7.0"
}

variable "database_cluster_type" {
  type        = string
  description = "Type of the MongoDB cluster"
  default     = "REPLICASET"
}

variable "database_cluster_instance_size" {
  type        = string
  description = "Database instance size"
  default     = "M10"
}

variable "database_shards" {
  type        = number
  description = "Number of shards to configure for the database"
  default     = 1
}

variable "database_electable_nodes" {
  type        = number
  description = "The number of electable nodes in the MongoDB cluster"
  default     = 3
}

variable "database_read_only_nodes" {
  type        = number
  description = "The number of read_only nodes in the MongoDB cluster"
  default     = null
}

variable "database_analytics_nodes" {
  type        = number
  description = "The number of analytics nodes in the MongoDB cluster"
  default     = null
}

variable "database_storage_size" {
  type        = number
  description = "The storage assigned to the database instance"
  default     = null
}

variable "database_storage_ipos" {
  type        = number
  description = "The disk IOPS to have for the database instance"
  default     = null
}

variable "database_storage_type" {
  type        = string
  description = "The storage type to use for the database instance"
  default     = null
}

variable "database_autoscaling_min_instances" {
  type        = number
  description = "The minimum number of instances to have in the database instance autoscaling group"
  default     = 1
}

variable "database_autoscaling_max_instances" {
  type        = number
  description = "The maximum number of instances to have in the database instance autoscaling group"
  default     = 3
}

variable "is_database_autoscaling_compute_enabled" {
  type        = bool
  description = "Whether to enable autoscaling of database instances"
  default     = false
}

variable "is_database_autoscaling_disk_gb_enabled" {
  type        = bool
  description = "Whether to enable autoscaling disk size for the database instance"
  default     = true
}

variable "database_backup_retention_period" {
  type        = number
  description = "The retention period for the database backups in days"
  default     = 35
}

variable "is_database_storage_encrypted" {
  type        = bool
  description = "Whether the database storage is encrypted in rest"
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to use for the MongoDB cluster"
}

variable "database_users" {
  type = map(object({
    username       = string
    database       = string
    forum_database = string
  }))
  default     = {}
  description = "Map of overrides for the user and database names."
}
