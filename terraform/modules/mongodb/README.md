## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | >= 1.21.0, < 2.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | >= 1.21.0, < 2.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [mongodbatlas_cloud_backup_schedule.backup_schedule](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cloud_backup_schedule) | resource |
| [mongodbatlas_cluster.cluster](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster) | resource |
| [mongodbatlas_database_user.users](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user) | resource |
| [mongodbatlas_project_ip_access_list.access](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list) | resource |
| [random_password.user_passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_atlas_provider_name"></a> [atlas\_provider\_name](#input\_atlas\_provider\_name) | Cloud that hosts the Atlas cluster: AWS, GCP, or AZURE. This is not the cloud that runs Kubernetes. | `string` | `"AWS"` | no |
| <a name="input_atlas_region_name"></a> [atlas\_region\_name](#input\_atlas\_region\_name) | Atlas region name, for example EU\_CENTRAL\_1. AWS callers pass the AWS region with hyphens replaced by underscores and uppercased. | `string` | n/a | yes |
| <a name="input_database_analytics_nodes"></a> [database\_analytics\_nodes](#input\_database\_analytics\_nodes) | The number of analytics nodes in the MongoDB cluster. | `number` | `null` | no |
| <a name="input_database_autoscaling_max_instances"></a> [database\_autoscaling\_max\_instances](#input\_database\_autoscaling\_max\_instances) | The maximum number of instances to have in the database instance autoscaling group. | `number` | `3` | no |
| <a name="input_database_autoscaling_min_instances"></a> [database\_autoscaling\_min\_instances](#input\_database\_autoscaling\_min\_instances) | The minimum number of instances to have in the database instance autoscaling group. | `number` | `1` | no |
| <a name="input_database_backup_retention_period"></a> [database\_backup\_retention\_period](#input\_database\_backup\_retention\_period) | The retention period for the database backups in days. | `number` | `35` | no |
| <a name="input_database_cluster_instance_size"></a> [database\_cluster\_instance\_size](#input\_database\_cluster\_instance\_size) | Database instance size. | `string` | `"M10"` | no |
| <a name="input_database_cluster_name"></a> [database\_cluster\_name](#input\_database\_cluster\_name) | The name of the MongoDB cluster. | `string` | n/a | yes |
| <a name="input_database_cluster_type"></a> [database\_cluster\_type](#input\_database\_cluster\_type) | Type of the MongoDB cluster. | `string` | `"REPLICASET"` | no |
| <a name="input_database_cluster_version"></a> [database\_cluster\_version](#input\_database\_cluster\_version) | The version of the MongoDB cluster. | `string` | `"7.0"` | no |
| <a name="input_database_electable_nodes"></a> [database\_electable\_nodes](#input\_database\_electable\_nodes) | The number of electable nodes in the MongoDB cluster. | `number` | `3` | no |
| <a name="input_database_read_only_nodes"></a> [database\_read\_only\_nodes](#input\_database\_read\_only\_nodes) | The number of read\_only nodes in the MongoDB cluster. | `number` | `null` | no |
| <a name="input_database_shards"></a> [database\_shards](#input\_database\_shards) | Number of shards to configure for the database. | `number` | `1` | no |
| <a name="input_database_storage_ipos"></a> [database\_storage\_ipos](#input\_database\_storage\_ipos) | The disk IOPS to have for the database instance. | `number` | `null` | no |
| <a name="input_database_storage_size"></a> [database\_storage\_size](#input\_database\_storage\_size) | The storage assigned to the database instance. | `number` | `null` | no |
| <a name="input_database_storage_type"></a> [database\_storage\_type](#input\_database\_storage\_type) | The storage type to use for the database instance. | `string` | `null` | no |
| <a name="input_database_users"></a> [database\_users](#input\_database\_users) | Map of additional user and database names. | <pre>map(object({<br/>    username = string<br/>    database = string<br/>  }))</pre> | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The project environment. (for example: production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_ip_access_cidrs"></a> [ip\_access\_cidrs](#input\_ip\_access\_cidrs) | CIDRs allowed to reach the cluster. AWS passes the VPC CIDR. UpCloud passes the NAT gateway public IP as a /32. | `list(string)` | n/a | yes |
| <a name="input_is_database_autoscaling_compute_enabled"></a> [is\_database\_autoscaling\_compute\_enabled](#input\_is\_database\_autoscaling\_compute\_enabled) | Whether to enable autoscaling of database instances. | `bool` | `false` | no |
| <a name="input_is_database_autoscaling_disk_gb_enabled"></a> [is\_database\_autoscaling\_disk\_gb\_enabled](#input\_is\_database\_autoscaling\_disk\_gb\_enabled) | Whether to enable autoscaling disk size for the database instance. | `bool` | `true` | no |
| <a name="input_is_database_storage_encrypted"></a> [is\_database\_storage\_encrypted](#input\_is\_database\_storage\_encrypted) | Use a customer-managed key from atlas\_provider\_name for encryption at rest. The Atlas project must already have that key configured. Atlas still encrypts disks with its own keys when this is false. | `bool` | `false` | no |
| <a name="input_mongodbatlas_project_id"></a> [mongodbatlas\_project\_id](#input\_mongodbatlas\_project\_id) | The ID of the MongoDB Atlas project. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_address"></a> [cluster\_address](#output\_cluster\_address) | The address of the database cluster. |
| <a name="output_cluster_connection_strings"></a> [cluster\_connection\_strings](#output\_cluster\_connection\_strings) | Connection strings for the database cluster. |
| <a name="output_database_cluster_cluster_id"></a> [database\_cluster\_cluster\_id](#output\_database\_cluster\_cluster\_id) | The cluster ID of the database cluster. |
| <a name="output_database_cluster_id"></a> [database\_cluster\_id](#output\_database\_cluster\_id) | The unique resource ID of the database cluster. |
| <a name="output_database_user_credentials"></a> [database\_user\_credentials](#output\_database\_user\_credentials) | List of database and user credentials mapping. |
