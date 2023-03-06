# Reference Architecture for AWS

This module includes Terraform modules to create AWS reference resources that are preconfigured to support Open edX as well as [Karpenter](https://karpenter.sh/) for management of [AWS EC2 spot-priced](https://aws.amazon.com/ec2/spot/) compute nodes as well as enhanced pod bin packing.

## Virtual Private Cloud (VPC)

There are no explicit requirements for Karpenter within this VPC defintion. However, there *are* several requirements for EKS which might vary from the VPC module defaults now or in the future. These include:

- defined sets of subnets for both private and public networks
- a NAT gateway
- enabling DNS host names
- custom resource tags for public and private subnets
- explicit assignments of AWS region and availability zones

See: [AWS VPC README](./vpc/README.rst)

## Elastic Kubernetes Service (EKS)

AWS EKS has grown more complex over time. This reference implementation is preconfigured as necessary to ensure that a.) you and others on your team can access the Kubernetes cluster both from the AWS Console as well as from kubectl, b.) it will work for an Open edX deployment, b
c.) it will work with Karpenter. With these goals in mind, please note the following configuration details:

- requirements detailed in the VPC section above are explicitly passed in to this module as inputs
- cluster endpoints for private and public access are enabled
- IAM Roles for Service Accounts (IRSA) is enabled
- Key Management Service (KMS) is enabled, encrypting all Kubernetes Secrets
- cluster access via aws-auth/configMap is enabled
- a karpenter.sh/discovery resource tag is added to the EKS instance
- various AWS EKS add-ons that are required by Open edX and/or Karpenter and/or its supporting systems (metrics-server, vpa, prometheus) are included
- additional cluster node security configuration is added to allow node-to-node and pod-to-pod communication using internal DNS resolution
- a managed node group is added containing custom labels, IAM roles, and resource tags; all of which are required by Karpenter
- adds additional resources required by AWS EBS CSI Driver add-on, itself required by EKS since 1.22
- additional EC2 security groups are added to enable pod shell access from kubectl

See: [AWS EKS README](./k8s-cluster/README.rst)