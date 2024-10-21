# Terraform AWS VPC and EKS Cluster Deployment

This guide provides a step-by-step process to deploy a Virtual Private Cloud (VPC) and an Elastic Kubernetes Service (EKS) cluster in AWS using Terraform.

## Prerequisites

Ensure the following tools and configurations are set up before proceeding:

- **Terraform** installed (version 1.5.6+).
- **AWS CLI** installed and configured with the appropriate credentials and region.
- **SSH Key Pair** created in AWS (you’ll need the key pair name for `key_name`).
- Proper IAM permissions to create VPC, EC2, and EKS resources.

## Steps for Deployment

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <repository-directory>
```

### 2. Initialize Terraform

Run the following command to initialize Terraform and download the required providers and modules:

``` bash
terraform init
```

### 3. Customize Variables

Edit the `variables.tf` file or edit the `values.auto.tfvars.json` file to override default values as needed. Below is a table describing the available variables:

| Variable                           | Description                                                                     | Type          | Default           |
|------------------------------------ |---------------------------------------------------------------------------------|---------------|-------------------|
| `aws_region`                       | The AWS Region in which to deploy the resources                                 | `string`      |                   |
| `private_subnets`                  | List of private subnets                                                         | `list(string)`| `[]`              |
| `public_subnets`                   | List of public subnets                                                          | `list(string)`| `[]`              |
| `cidr`                             | CIDR block for the VPC                                                          | `string`      | `10.0.0.0/16`     |
| `azs`                              | List of availability zones to use                                               | `list(string)`| `[]`              |
| `vpc_name`                         | The VPC name                                                                    | `string`      |                   |
| `enable_nat_gateway`               | Enable NAT Gateway                                                              | `bool`        | `true`            |
| `single_nat_gateway`               | Use a single NAT Gateway                                                        | `bool`        | `false`           |
| `one_nat_gateway_per_az`           | Deploy one NAT gateway per availability zone                                    | `bool`        | `true`            |
| `instance_types`                   | EC2 Instance types for the Kubernetes nodes                                     | `list(string)`|                   |
| `cluster_version`                  | Kubernetes version for the EKS cluster                                          | `string`      | `1.29`            |
| `cluster_name`                     | Name of the EKS cluster                                                         | `string`      |                   |
| `desired_size`                     | Desired number of nodes in the EKS cluster                                      | `number`      | `2`               |
| `disk_size`                        | Disk size for the nodes (in GB)                                                 | `number`      | `40`              |
| `key_name`                         | Name of the SSH Key Pair                                                        | `string`      |                   |
| `max_size`                         | Maximum number of nodes in the EKS cluster                                      | `number`      | `3`               |
| `min_size`                         | Minimum number of nodes in the EKS cluster                                      | `number`      | `1`               |
| `extra_ssh_cidrs`                  | List of additional IP blocks allowed SSH access                                 | `list(string)`| `[]`              |
| `registry_credentials`             | Image registry credentials for the nodes                                        | `string`      |                   |
| `node_groups_tags`                 | A map of tags to add to all node group resources                                | `map(string)` | `{}`              |
| `enable_cluster_autoscaler`        | Enable cluster autoscaler for the EKS cluster                                   | `bool`        | `false`           |
| `ubuntu_version`                   | Ubuntu version for the nodes (default: `jammy-22.04`)                           | `string`      | `jammy-22.04`     |
| `ami_id`                           | AMI ID for EKS nodes (optional)                                                 | `string`      | `""`              |
| `iam_role_use_name_prefix`         | Use a name prefix for the IAM role associated with the cluster                  | `bool`        | `true`            |
| `iam_role_name`                    | IAM Role name for the cluster                                                   | `string`      | `null`            |
| `cluster_security_group_use_name_prefix`| Use a name prefix for the cluster security group                            | `bool`        | `true`            |
| `cluster_security_group_name`      | Security group name for the cluster                                             | `string`      | `null`            |
| `cluster_security_group_description`| Description of the cluster security group                                      | `string`      | `EKS cluster security group` |
| `node_group_subnets`               | Subnets for node groups (typically private)                                     | `list(string)`| `null`            |
| `cluster_tags`                     | A map of tags to add to the cluster                                             | `map(string)` | `{}`              |
| `tags`                             | A map of tags to add to all resources                                           | `map(string)` | `{}`              |
| `node_group_name`                  | Name of the node group                                                          | `string`      | `ubuntu_worker`   |
| `capacity_type`                    | Type of capacity for EKS Node Group (options: `ON_DEMAND`, `SPOT`)              | `string`      | `ON_DEMAND`       |
| `post_bootstrap_user_data`         | Add post-bootstrap user data (optional)                                         | `string`      | `null`            |

### 4. Apply the Terraform Configuration

Run the following command to deploy the infrastructure:

```bash
  terraform apply
```

### 5. Access the EKS Cluster

Once the deployment is complete, you can configure your kubectl to access the EKS cluster:

```bash
  aws eks --region <aws-region> update-kubeconfig --name <cluster-name>
```

### 6. Clean Up

To destroy the infrastructure when you no longer need it, run:

```bash
  terraform destroy
```
