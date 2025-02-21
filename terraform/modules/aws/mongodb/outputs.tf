output "database_cluster_id" {
  value       = mongodbatlas_cluster.cluster.id
  description = "The unique resource ID of the database cluster"
}

output "database_cluster_cluster_id" {
  value       = mongodbatlas_cluster.cluster.cluster_id
  description = "The cluster ID of the database cluster"
}

output "cluster_address" {
  value       = mongodbatlas_cluster.cluster.srv_address
  description = "The address of the database cluster"
}

output "cluster_connection_strings" {
  value       = mongodbatlas_cluster.cluster.connection_strings
  description = "Connection strings for the database cluster"
}

output "database_user_credentials" {
  value = {
    for key, user in var.database_users :
    key => {
      username       = user.username
      password       = try(mongodbatlas_database_user.users[user.username].password, "")
      database       = user.database
    }
  }
  description = "List of database and user credentials mapping."
  sensitive   = true
}
