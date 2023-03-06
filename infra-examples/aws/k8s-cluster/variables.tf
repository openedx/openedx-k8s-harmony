#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------
variable "account_id" {
  description = "a 12-digit AWS account id, all integers. example: 012345678999"
  type        = string
}

variable "shared_resource_identifier" {
  description = "a prefix to add to all resource names associated with this Kubernetes cluster instance"
  type        = string
  default     = ""
}

variable "name" {
  description = "a valid Kubernetes name definition"
  type        = string
  default     = "openedx-k8s-harmony"
}

variable "aws_region" {
  description = "the AWS region code. example: us-east-1. see https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html"
  type        = string
  default     = "us-east-1"
}


variable "enable_irsa" {
  description = "true to create an OpenID Connect Provider for EKS to enable IRSA (IAM Roles for Service Accounts)."
  type        = bool
  default     = true
}

variable "kubernetes_cluster_version" {
  description = "the Kubernetes release for this cluster"
  type        = string
  default     = "1.25"
}

variable "eks_create_kms_key" {
  description = "true to create an AWS Key Management Service (KMS) key for encryption of all Kubernetes secrets in this cluster."
  type        = bool
  default     = true
}

variable "eks_service_group_instance_type" {
  description = "AWS EC2 instance type to deploy into the 'service' AWS EKS Managed Node Group"
  type        = string
  default     = "t3.large"
}

variable "eks_service_group_min_size" {
  description = "The minimum number of AWS EC2 instance nodes to run in the 'service' AWS EKS Managed Node Group"
  type        = number
  default     = 3
}

variable "eks_service_group_max_size" {
  description = "The maximum number of AWS EC2 instance nodes to run in the 'service' AWS EKS Managed Node Group"
  type        = number
  default     = 3
}

variable "eks_service_group_desired_size" {
  description = "Only read during cluster creation. The desired number of AWS EC2 instance nodes to run in the 'service' AWS EKS Managed Node Group"
  type        = number
  default     = 3
}

# sample data:
# -----------------------------------------------------------------------------
# map_users = [
#     {
#       userarn  = "arn:aws:iam::012345678999:user/mcdaniel"
#       username = "mcdaniel"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws:iam::012345678999:user/bob_marley"
#       username = "bob_marley"
#       groups   = ["system:masters"]
#     },
#]
variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

# sample data:
# -----------------------------------------------------------------------------
# kms_key_owners = [
#   "arn:aws:iam::012345678999:user/mcdaniel",
#   "arn:aws:iam::012345678999:user/bob_marley",
# ]
variable "kms_key_owners" {
  type    = list(any)
  default = []
}
