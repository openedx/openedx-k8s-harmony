output "database_cluster_id" {
  value       = mongodbatlas_advanced_cluster.cluster.cluster_id
  description = "The unique resource ID of the database cluster."
}

output "database_cluster_cluster_id" {
  value       = mongodbatlas_advanced_cluster.cluster.cluster_id
  description = "The cluster ID of the database cluster."
}

output "atlas_cluster_name" {
  value       = mongodbatlas_advanced_cluster.cluster.name
  description = "Atlas cluster name, including the environment suffix."
}

output "atlas_srv_address" {
  value       = mongodbatlas_advanced_cluster.cluster.connection_strings.standard_srv
  description = "MongoDB Atlas SRV address."
}

output "cluster_connection_strings" {
  value       = mongodbatlas_advanced_cluster.cluster.connection_strings
  description = "Connection strings for the database cluster."
}

output "database_user_credentials" {
  value = {
    for key, user in var.database_users :
    key => {
      username = user.username
      password = random_password.user_passwords[user.username].result
      database = user.database
    }
  }
  description = "List of database and user credentials mapping."
  sensitive   = true
}
