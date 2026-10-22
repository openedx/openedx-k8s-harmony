output "cluster_id" {
  value       = upcloud_kubernetes_cluster.cluster.id
  description = "UUID of the Kubernetes cluster."
}

output "cluster_name" {
  value       = upcloud_kubernetes_cluster.cluster.name
  description = "Name of the Kubernetes cluster."
}

output "cluster_endpoint" {
  value       = data.upcloud_kubernetes_cluster.cluster.host
  description = "URI of the Kubernetes API."
}

output "kubeconfig" {
  value       = data.upcloud_kubernetes_cluster.cluster.kubeconfig
  description = "Kubeconfig for the cluster. Contains client credentials."
  sensitive   = true
}

output "client_certificate" {
  value       = data.upcloud_kubernetes_cluster.cluster.client_certificate
  description = "PEM client certificate for the Kubernetes API."
  sensitive   = true
}

output "client_key" {
  value       = data.upcloud_kubernetes_cluster.cluster.client_key
  description = "PEM client key for the Kubernetes API."
  sensitive   = true
}

output "cluster_ca_certificate" {
  value       = data.upcloud_kubernetes_cluster.cluster.cluster_ca_certificate
  description = "PEM certificate authority for the Kubernetes API."
  sensitive   = true
}

output "node_groups" {
  value = concat(
    [
      {
        name           = upcloud_kubernetes_node_group.workers.name
        min_node_count = var.worker_node_min_count
        max_node_count = var.worker_node_max_count
      },
    ],
    [
      for pool in var.additional_node_pools : {
        name           = pool.name
        min_node_count = pool.min_node_count
        max_node_count = pool.max_node_count
      }
    ],
  )
  description = "Node groups and the size range Cluster Autoscaler may apply to each one."
}
