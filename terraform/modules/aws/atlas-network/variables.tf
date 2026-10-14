variable "region" {
  type        = string
  description = "AWS region of the VPC. Used as the peering accepter region."
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID that owns the VPC."
}

variable "atlas_project_id" {
  type        = string
  description = "The ID of the MongoDB Atlas project."
}

variable "atlas_region_name" {
  type        = string
  description = "Atlas region name, for example US_EAST_1. Callers pass the AWS region with hyphens replaced by underscores and uppercased."
}

variable "atlas_cidr_block" {
  type        = string
  description = "CIDR block Atlas uses for the peered network container."

  validation {
    condition     = can(cidrhost(var.atlas_cidr_block, 0))
    error_message = "atlas_cidr_block must be a valid CIDR block."
  }
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to peer with the Atlas network container."
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "Private route table IDs that should route to the Atlas peering connection."
}
