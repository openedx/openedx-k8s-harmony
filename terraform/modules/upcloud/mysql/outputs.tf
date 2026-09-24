output "database_cluster_id" {
  value       = upcloud_managed_database_mysql.this.id
  description = "UUID of the MySQL service."
}

output "database_cluster_root_user" {
  value       = upcloud_managed_database_mysql.this.service_username
  description = "Primary MySQL username."
  sensitive   = true
}

output "database_cluster_root_password" {
  value       = upcloud_managed_database_mysql.this.service_password
  description = "Primary MySQL password."
  sensitive   = true
}

output "cluster_host" {
  value       = upcloud_managed_database_mysql.this.service_host
  description = "Hostname of the MySQL service."
}

output "cluster_port" {
  value       = upcloud_managed_database_mysql.this.service_port
  description = "Port of the MySQL service."
}

output "cluster_connection_endpoint" {
  value       = upcloud_managed_database_mysql.this.service_uri
  description = "Connection URI of the MySQL service."
  sensitive   = true
}

output "database_user_credentials" {
  value = {
    for key, val in var.database_users :
    key => {
      username = val.username
      password = random_password.database_user[key].result
      database = val.database
    }
  }
  description = "Additional database users and their passwords."
  sensitive   = true
}
