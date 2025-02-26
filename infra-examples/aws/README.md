# AWS Infrastructure Example

This is an example implementation to create a production grade infrastructure for hosting Open edX instances on AWS, using the Terraform modules provided by Harmony.

## Important notes

Be aware that the current implementation does not support the creation of MongoDB users and S3 buckets through Tutor plugins.

MongoDB Atlas does not provide an equivalent to `rds_root_username`, making it impractical to automate user creation for each instance. Consequently, while Tutor can handle MySQL database and user creation, Terraform is required (as of now) for setting up MongoDB databases and users. This approach is not ideal as it necessitates running Terraform code when adding or removing instances, which contradicts the goal of separating cluster provisioning from instance provisioning. Until a more streamlined solution, such as a plugin or automation tool, is developed, users must manually manage these resources. For now, please ensure you manually configure MongoDB users and S3 buckets to maintain a fully functional environment (either using Terraform or other methods).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.88 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.88 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bucket"></a> [bucket](#module\_bucket) | ../../terraform/modules/aws/s3 | n/a |
| <a name="module_kubernetes_cluster"></a> [kubernetes\_cluster](#module\_kubernetes\_cluster) | ../../terraform/modules/aws/eks | n/a |
| <a name="module_main_vpc"></a> [main\_vpc](#module\_main\_vpc) | ../../terraform/modules/aws/vpc | n/a |
| <a name="module_mongodb_database"></a> [mongodb\_database](#module\_mongodb\_database) | ../../terraform/modules/aws/mongodb | n/a |
| <a name="module_mysql_database"></a> [mysql\_database](#module\_mysql\_database) | ../../terraform/modules/aws/rds | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_docker_registry_credentials"></a> [docker\_registry\_credentials](#input\_docker\_registry\_credentials) | Image registry credentials to be added to the K8s worker nodes | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The AWS project environment. (for example: production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#input\_kubernetes\_cluster\_name) | Name of the Kubernetes cluster to create. | `string` | n/a | yes |
| <a name="input_mongodbatlas_cidr_block"></a> [mongodbatlas\_cidr\_block](#input\_mongodbatlas\_cidr\_block) | The CIDR block in MongoDB Atlas | `string` | n/a | yes |
| <a name="input_mongodbatlas_project_id"></a> [mongodbatlas\_project\_id](#input\_mongodbatlas\_project\_id) | The ID of the MongoDB Atlas project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS Region in which to deploy the resources | `string` | n/a | yes |
| <a name="input_worker_node_ssh_key_name"></a> [worker\_node\_ssh\_key\_name](#input\_worker\_node\_ssh\_key\_name) | Name of the SSH Key Pair used for the worker nodes | `string` | n/a | yes |

## Outputs

No outputs.
