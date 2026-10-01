output "network_id" {
  value       = upcloud_network.this.id
  description = "UUID of the private network."
}

output "network_cidr" {
  value       = upcloud_network.this.ip_network[0].address
  description = "CIDR of the private network."
}

output "router_id" {
  value       = upcloud_router.this.id
  description = "UUID of the router attached to the private network."
}

output "gateway_id" {
  value       = one(upcloud_gateway.this[*].id)
  description = "UUID of the NAT gateway. Null when the gateway is disabled."
}

output "gateway_public_ip" {
  value = one(flatten([
    for gateway in upcloud_gateway.this : [
      for address in gateway.address : address.address
    ]
  ]))
  description = "Public IPv4 address of the NAT gateway. Null when the gateway is disabled."
}
