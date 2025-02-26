output "cluster_id" {
  value = digitalocean_kubernetes_cluster.cluster.id
  description = "The ID of the Kubernetes cluster that is generated during creation."
}

output "cluster_urn" {
  value = digitalocean_kubernetes_cluster.cluster.urn
  description = "The unique resource ID of the Kubernetes cluster."
}

output "cluster_name" {
  value = digitalocean_kubernetes_cluster.cluster.name
  description = "The name of the Kubernetes cluster."
}

output "cluster_ipv4" {
  value = digitalocean_kubernetes_cluster.cluster.ipv4_address
  description = "IPv4 address of the Kubernetes cluster."
}

output "cluster_endpoint" {
  value = digitalocean_kubernetes_cluster.cluster.endpoint
  description = "Endpoint of the Kubernetes cluster."
}
