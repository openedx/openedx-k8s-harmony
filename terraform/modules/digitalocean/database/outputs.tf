output "cluster_id" {
  value     = digitalocean_database_cluster.database_cluster.id
  description = "The unique resource ID of the database cluster."
}

output "cluster_urn" {
  value     = digitalocean_database_cluster.database_cluster.urn
  description = "The unique resource ID of the database cluster."
}

output "cluster_root_user" {
  value     = digitalocean_database_cluster.database_cluster.user
  description = "Database root user"
  sensitive = true
}

output "cluster_root_password" {
  value     = digitalocean_database_cluster.database_cluster.password
  description = "Database root user password"
  sensitive = true
}

output "cluster_host" {
  value = digitalocean_database_cluster.database_cluster.host
  description = "The hostname of the database cluster."
}

output "cluster_port" {
  value = digitalocean_database_cluster.database_cluster.port
  description = "The port on which the database cluster is waiting for client connections."
}

output "cluster_connection_string" {
  value = digitalocean_database_cluster.database_cluster.uri
  description = "The URI to use as a connection string for the database cluster."
}

output "database_user_credentials" {
  value = {
    for key, val in var.database_users :
    key => {
      username = val.username
      password = try(digitalocean_database_user.users[val.username].password, "")
      database = try(digitalocean_database_db.databases[val.username].name, "")
    }
  }
  description = "List of database and user credentials mapping."
  sensitive = true
}
