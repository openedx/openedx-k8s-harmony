## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster_autoscaler_irsa_role"></a> [cluster\_autoscaler\_irsa\_role](#module\_cluster\_autoscaler\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.47 |
| <a name="module_ebs_csi_irsa_role"></a> [ebs\_csi\_irsa\_role](#module\_ebs\_csi\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.47 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 20.31 |

## Resources

| Name | Type |
|------|------|
| [aws_ami.latest_ubuntu_eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_subnets.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | EKS nodes AMI ID | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the Kubernetes cluster. | `string` | n/a | yes |
| <a name="input_cluster_security_group_description"></a> [cluster\_security\_group\_description](#input\_cluster\_security\_group\_description) | Cluster security group description | `string` | `"EKS cluster security group"` | no |
| <a name="input_cluster_security_group_name"></a> [cluster\_security\_group\_name](#input\_cluster\_security\_group\_name) | Cluster security group name | `string` | `null` | no |
| <a name="input_cluster_security_group_use_name_prefix"></a> [cluster\_security\_group\_use\_name\_prefix](#input\_cluster\_security\_group\_use\_name\_prefix) | Determinate if it is necessary to create an security group prefix for the cluster | `bool` | `true` | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | A map of tags to add to the cluster | `map(string)` | `{}` | no |
| <a name="input_enable_cluster_autoscaler"></a> [enable\_cluster\_autoscaler](#input\_enable\_cluster\_autoscaler) | Determines whether to prepare the cluster to use cluster autoscaler | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The AWS project environment. (for example: production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Cluster IAM role name | `string` | `null` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determinate if it is necessary to create an iam role prefix for the cluster | `bool` | `true` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The supported Kubernetes version to install for the cluster. | `string` | n/a | yes |
| <a name="input_max_worker_node_count"></a> [max\_worker\_node\_count](#input\_max\_worker\_node\_count) | Maximum node count in the autoscaling group | `number` | `3` | no |
| <a name="input_min_worker_node_count"></a> [min\_worker\_node\_count](#input\_min\_worker\_node\_count) | Minimum node count in the autoscaling group | `number` | `1` | no |
| <a name="input_post_bootstrap_user_data"></a> [post\_bootstrap\_user\_data](#input\_post\_bootstrap\_user\_data) | Allow to add post bootstrap user data | `string` | `null` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnets | `list(string)` | <pre>[<br/>  "10.10.0.0/21",<br/>  "10.10.8.0/21"<br/>]</pre> | no |
| <a name="input_registry_credentials"></a> [registry\_credentials](#input\_registry\_credentials) | Image registry credentials to be added to the node | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_ubuntu_version"></a> [ubuntu\_version](#input\_ubuntu\_version) | Ubuntu version to use (e.g. focal-20.04) when no ami\_id is provided | `string` | `"jammy-22.04"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC to use for the Kubernetes cluster. | `string` | n/a | yes |
| <a name="input_worker_node_capacity_type"></a> [worker\_node\_capacity\_type](#input\_worker\_node\_capacity\_type) | Type of capacity associated with the EKS Node Group. Valid values: `ON_DEMAND`, `SPOT` | `string` | `"ON_DEMAND"` | no |
| <a name="input_worker_node_count"></a> [worker\_node\_count](#input\_worker\_node\_count) | Desired autoscaling node count | `number` | `2` | no |
| <a name="input_worker_node_disk_size"></a> [worker\_node\_disk\_size](#input\_worker\_node\_disk\_size) | Node disk size | `number` | `40` | no |
| <a name="input_worker_node_extra_ssh_cidrs"></a> [worker\_node\_extra\_ssh\_cidrs](#input\_worker\_node\_extra\_ssh\_cidrs) | List of additional IP blocks with ssh access to the worker nodes | `list(string)` | `[]` | no |
| <a name="input_worker_node_group_name"></a> [worker\_node\_group\_name](#input\_worker\_node\_group\_name) | Name of the node group | `string` | `"ubuntu_worker"` | no |
| <a name="input_worker_node_groups_tags"></a> [worker\_node\_groups\_tags](#input\_worker\_node\_groups\_tags) | A map of tags to add to all node group resources | `map(string)` | `{}` | no |
| <a name="input_worker_node_instance_types"></a> [worker\_node\_instance\_types](#input\_worker\_node\_instance\_types) | EC2 Instance type for the nodes | `list(string)` | n/a | yes |
| <a name="input_worker_node_ssh_key_name"></a> [worker\_node\_ssh\_key\_name](#input\_worker\_node\_ssh\_key\_name) | Name of the SSH Key Pair used for the worker nodes | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for your Kubernetes API server |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the EKS cluster |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | The Kubernetes version for the cluster |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | The ARN of the VPC |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
