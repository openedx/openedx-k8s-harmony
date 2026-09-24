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
