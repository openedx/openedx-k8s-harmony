output "vpc_id" {
  value = digitalocean_vpc.vpc.id
  description = "The ID of the VPC that is generated during creation."
}

output "vpc_urn" {
  value = digitalocean_vpc.vpc.urn
  description = "The unique resource ID of the VPC."
}

output "vpc_name" {
  value = digitalocean_vpc.vpc.name
  description = "The name of the VPC, including the generated suffix, if any."
}

output "vpc_ip_range" {
  value = digitalocean_vpc.vpc.ip_range
  description = "The IP range that is covered by the VPC."
}
