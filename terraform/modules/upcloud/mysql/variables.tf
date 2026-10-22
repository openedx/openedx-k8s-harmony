variable "environment" {
  type        = string
  description = "The UpCloud project environment. (for example: production, staging, development, etc.)"
}

variable "zone" {
  type        = string
  description = "UpCloud zone for the database. Must match the private network zone."
}

variable "network_id" {
  type        = string
  description = "UUID of the private network to attach."
}

variable "network_cidr" {
  type        = string
  description = "CIDR allowed to connect to MySQL. Public access is disabled."
}

variable "database_cluster_name" {
  type        = string
  description = "Service name and hostname prefix. Must be unique in the account."
}

variable "plan" {
  type        = string
  default     = "1x1xCPU-2GB-25GB"
  description = "Managed MySQL plan. List plans with `upctl database plans mysql`."
}

variable "maintenance_window_dow" {
  type        = string
  default     = "sunday"
  description = "Maintenance window day of week, in lowercase."

  validation {
    condition = contains([
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday",
    ], var.maintenance_window_dow)
    error_message = "Maintenance day must be a lowercase weekday name."
  }
}

variable "maintenance_window_time" {
  type        = string
  default     = "01:00:00"
  description = "Maintenance window UTC time in hh:mm:ss format."
}

variable "database_users" {
  type = map(object({
    username = string
    database = string
  }))
  default     = {}
  description = "Additional logical databases and users. Keys are arbitrary; username and database set the created names."
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels applied to the MySQL service."
}
