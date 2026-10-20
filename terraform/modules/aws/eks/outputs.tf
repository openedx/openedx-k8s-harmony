output "vpc_id" {
  description = "The ID of the VPC"
  value       = data.aws_vpc.main.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = data.aws_vpc.main.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = data.aws_vpc.main.cidr_block
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.eks.cluster_version
}

output "worker_node_iam_role_name" {
  description = "The name of the IAM role used by the worker node group"
  value       = module.eks.eks_managed_node_groups["ubuntu_worker"].iam_role_name
}
