output "database_cluster_id" {
  value       = module.cluster.database_cluster_id
  description = "The unique resource ID of the database cluster"
}

output "database_cluster_cluster_id" {
  value       = module.cluster.database_cluster_cluster_id
  description = "The cluster ID of the database cluster"
}

output "cluster_address" {
  value       = module.cluster.cluster_address
  description = "The address of the database cluster"
}

output "cluster_connection_strings" {
  value       = module.cluster.cluster_connection_strings
  description = "Connection strings for the database cluster"
}

output "database_user_credentials" {
  value       = module.cluster.database_user_credentials
  description = "List of database and user credentials mapping."
  sensitive   = true
}
