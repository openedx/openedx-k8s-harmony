variable "environment" {
  type        = string
  description = "The AWS project environment. (for example: production, staging, development, etc.)"
}

variable "database_cluster_name" {
  type        = string
  description = "The name of the database cluster"
}

variable "database_engine" {
  type        = string
  description = "Database engine name"
  default     = "mysql"
}

variable "database_engine_version" {
  type        = string
  description = "Database engine version"
  default     = "8.0"
}

variable "database_cluster_instance_size" {
  type        = string
  description = "Database instance size"
  default     = "db.t3.micro"
}

variable "database_min_storage" {
  type        = number
  description = "The minimum storage assigned to the database instance"
  default     = 15
}

variable "database_max_storage" {
  type        = number
  description = "The maximum storage assigned to the database instance"
  default     = 30
}

variable "database_backup_retention_period" {
  type        = number
  description = "The retention period for the database backups in days"
  default     = 35
}

variable "database_ca_cert_identifier" {
  type        = string
  description = "The CA certificate identifier if any"
  default     = null
}

variable "database_storage_alarm_threshold" {
  type        = number
  description = "The threshold for database storage usage that triggers the alarm in bytes"
  default     = 1000000000
}

variable "database_storage_alarm_period" {
  type        = number
  description = "Evaluation periods for the usage in seconds"
  default     = 300
}

variable "database_storage_alarm_evaluation_periods" {
  type        = number
  description = "The number of periods that need to violate the threshold before alarming"
  default     = 1
}

variable "database_storage_alarm_alarm_actions" {
  type        = list(string)
  description = "List of ARNs of actions to execute when the RDS storage alarm is triggered"
  default     = []
}

variable "is_database_storage_encrypted" {
  type        = bool
  description = "Whether the database storage is encrypted in rest"
  default     = true
}

variable "is_auto_minor_version_upgrade_enabled" {
  type        = bool
  description = "Whether automatic minor version upgrades are enabled"
  default     = false
}

variable "is_auto_major_version_upgrade_enabled" {
  type        = bool
  description = "Whether automatic major version upgrades are enabled"
  default     = false
}

variable "is_database_storage_alarm_enabled" {
  type        = bool
  description = "Whether database storage alarms are enabled"
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to use for the RDS cluster"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}
