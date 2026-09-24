variable "environment" {
  type        = string
  description = "The UpCloud project environment. (for example: production, staging, development, etc.)"
}

variable "zone" {
  type        = string
  description = "UpCloud zone for the private network and NAT gateway, for example de-fra1."
}

variable "network_name" {
  type        = string
  default     = ""
  description = "Name of the private network. Empty generates open-edx-<environment>-<suffix>."
}

variable "ip_network_address" {
  type        = string
  default     = "10.0.0.0/24"
  description = "IPv4 CIDR of the single SDN subnet. UpCloud allows one ip_network per network."
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Create a NAT gateway and advertise it as the DHCP default route. Required for private UKS node groups."
}

variable "gateway_plan" {
  type        = string
  default     = "development"
  description = "NAT gateway plan. List plans with `upctl gateway plans`."
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels applied to the router, network, and gateway."
}
