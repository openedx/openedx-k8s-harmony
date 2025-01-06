output "database_cluster_id" {
  value       = aws_db_instance.rds_instance.id
  description = "The unique resource ID of the database cluster"
}

output "database_cluster_arn" {
  value       = aws_db_instance.rds_instance.arn
  description = "The unique resource ID of the database cluster"
}

output "database_cluster_root_user" {
  value       = random_string.rds_root_username.result
  description = "Database root user"
  sensitive   = true
}

output "database_cluster_root_password" {
  value       = random_password.rds_root_password.result
  description = "Database root user password"
  sensitive   = true
}

output "cluster_host" {
  value       = aws_db_instance.rds_instance.address
  description = "The hostname of the database cluster"
}

output "cluster_port" {
  value       = aws_db_instance.rds_instance.port
  description = "The port on which the database cluster is waiting for client connections"
}

output "cluster_connection_endpoint" {
  value       = aws_db_instance.rds_instance.endpoint
  description = "The endpoint URL on which the database cluster is accessible"
}
