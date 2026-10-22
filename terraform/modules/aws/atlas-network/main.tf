terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.62"
    }

    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 2.17"
    }
  }
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

# Network container to define the MongoDB Atlas CIDR block
resource "mongodbatlas_network_container" "cluster_network_container" {
  project_id       = var.atlas_project_id
  atlas_cidr_block = var.atlas_cidr_block
  provider_name    = "AWS"
  region_name      = var.atlas_region_name
}

# Peering between MongoDB Atlas and VPC
resource "mongodbatlas_network_peering" "cluster_network_peering" {
  project_id             = var.atlas_project_id
  container_id           = mongodbatlas_network_container.cluster_network_container.id
  accepter_region_name   = var.region
  provider_name          = "AWS"
  route_table_cidr_block = data.aws_vpc.main.cidr_block
  vpc_id                 = var.vpc_id
  aws_account_id         = var.aws_account_id
}

# Auto accept peering connection request
resource "aws_vpc_peering_connection_accepter" "accept_mongo_peer" {
  vpc_peering_connection_id = mongodbatlas_network_peering.cluster_network_peering.connection_id
  auto_accept               = true
}

# Add peering connection to private routing tables so EKS nodes can reach Atlas
resource "aws_route" "peeraccess" {
  count = length(var.private_route_table_ids)

  route_table_id            = var.private_route_table_ids[count.index]
  destination_cidr_block    = var.atlas_cidr_block
  vpc_peering_connection_id = mongodbatlas_network_peering.cluster_network_peering.connection_id
  depends_on = [
    aws_vpc_peering_connection_accepter.accept_mongo_peer
  ]
}
