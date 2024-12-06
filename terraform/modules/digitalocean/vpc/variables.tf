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
  description = "The DigitalOcean project environment."
}

variable "vpc_name" {
  type = string
  default = ""
  description = "Optional custom name for the VPC. If not provided, a name will be generated."
}

variable "vpc_ip_range" {
  type        = string
  default     = "10.10.0.0/24"
  description = "IP range assigned to the VPC."
}
