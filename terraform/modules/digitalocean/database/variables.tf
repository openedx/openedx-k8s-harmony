variable "access_token" {
  type = string
  description = "DigitalOcean access token in order to patch the database settings."
}

variable "region" {
  type        = string
  description = "DigitalOcean region to create the resources in."
  validation {
    condition = contains([
      "ams3",
      "blr1",
      "fra1",
      "lon1",
      "nyc3",
      "sfo2",
      "sfo3",
      "sgp1",
      "syd1",
      "tor1",
    ], var.region)
    error_message = "The DigitalOcean region must be in the acceptable region list."
  }
}

variable "environment" {
  type        = string
  description = "The DigitalOcean project environment. (for example: production, staging, development, etc.)"
}

variable "database_engine" {
  type        = string
  description = "Database engine name."
}

variable "database_engine_version" {
  type        = string
  description = "Database engine version."
}


variable "database_cluster_instances" {
  type        = number
  default     = 1
  description = "Number of nodes in the database cluster."
}

variable "database_cluster_instance_size" {
  type        = string
  default     = "s-1vcpu-1gb"
  description = "Database instance size."
}

variable "database_maintenance_window_day" {
  type = string
  default = "sunday"
  description = "The day when maintenance can be executed on the database cluster."
  
  validation {
    condition = contains([
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday",
    ], var.database_maintenance_window_day)
    error_message = "The day of the week on which to apply maintenance updates."
  }
}

variable "database_maintenance_window_time" {
  type = string
  description = "The hour in UTC at which maintenance updates will be applied in 24 hour format."
}

variable "database_users" {
  type = map(object({
    username = string
    database = string
  }))
  default     = {}
  description = "Map of overrides for the user and database names."
}

variable "kubernetes_cluster_name" {
  type = string
  description = "The name of the Kubernetes cluster."
}

variable "vpc_id" {
  type = string
  description = "ID of the VPC to use for the Kubernetes cluster."
}

variable "firewall_rules" {
  type = list(object({
    type  = string
    value = string
  }))
  description = "List of rules to apply on the related firewalls."

  validation {
    condition = alltrue([
      for rule in var.firewall_rules : contains(["droplet", "k8s", "ip_addr", "tag", "app"], rule.type)
    ])
    error_message = "The DigitalOcean database cluster's firewall rule must be one of \"droplet\", \"k8s\", \"ip_addr\", \"tag\", or \"app\"."
  }
}
