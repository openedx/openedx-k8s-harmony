## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.rds_storage_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_db_instance.rds_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.rds_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_kms_key.rds_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_security_group.rds_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_password.rds_root_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.rds_final_snapshot_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.rds_root_username](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_subnets.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database_backup_retention_period"></a> [database\_backup\_retention\_period](#input\_database\_backup\_retention\_period) | The retention period for the database backups in days | `number` | `35` | no |
| <a name="input_database_ca_cert_identifier"></a> [database\_ca\_cert\_identifier](#input\_database\_ca\_cert\_identifier) | The CA certificate identifier if any | `string` | `null` | no |
| <a name="input_database_cluster_instance_size"></a> [database\_cluster\_instance\_size](#input\_database\_cluster\_instance\_size) | Database instance size | `string` | `"db.t3.micro"` | no |
| <a name="input_database_cluster_name"></a> [database\_cluster\_name](#input\_database\_cluster\_name) | The name of the database cluster | `string` | n/a | yes |
| <a name="input_database_engine"></a> [database\_engine](#input\_database\_engine) | Database engine name | `string` | `"mysql"` | no |
| <a name="input_database_engine_version"></a> [database\_engine\_version](#input\_database\_engine\_version) | Database engine version | `string` | `"8.0"` | no |
| <a name="input_database_max_storage"></a> [database\_max\_storage](#input\_database\_max\_storage) | The maximum storage assigned to the database instance | `number` | `30` | no |
| <a name="input_database_min_storage"></a> [database\_min\_storage](#input\_database\_min\_storage) | The minimum storage assigned to the database instance | `number` | `15` | no |
| <a name="input_database_storage_alarm_alarm_actions"></a> [database\_storage\_alarm\_alarm\_actions](#input\_database\_storage\_alarm\_alarm\_actions) | List of ARNs of actions to execute when the RDS storage alarm is triggered | `list(string)` | `[]` | no |
| <a name="input_database_storage_alarm_evaluation_periods"></a> [database\_storage\_alarm\_evaluation\_periods](#input\_database\_storage\_alarm\_evaluation\_periods) | The number of periods that need to violate the threshold before alarming | `number` | `1` | no |
| <a name="input_database_storage_alarm_period"></a> [database\_storage\_alarm\_period](#input\_database\_storage\_alarm\_period) | Evaluation periods for the usage in seconds | `number` | `300` | no |
| <a name="input_database_storage_alarm_threshold"></a> [database\_storage\_alarm\_threshold](#input\_database\_storage\_alarm\_threshold) | The threshold for database storage usage that triggers the alarm in bytes | `number` | `1000000000` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The AWS project environment. (for example: production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_is_auto_major_version_upgrade_enabled"></a> [is\_auto\_major\_version\_upgrade\_enabled](#input\_is\_auto\_major\_version\_upgrade\_enabled) | Whether automatic major version upgrades are enabled | `bool` | `false` | no |
| <a name="input_is_auto_minor_version_upgrade_enabled"></a> [is\_auto\_minor\_version\_upgrade\_enabled](#input\_is\_auto\_minor\_version\_upgrade\_enabled) | Whether automatic minor version upgrades are enabled | `bool` | `false` | no |
| <a name="input_is_database_storage_alarm_enabled"></a> [is\_database\_storage\_alarm\_enabled](#input\_is\_database\_storage\_alarm\_enabled) | Whether database storage alarms are enabled | `bool` | `true` | no |
| <a name="input_is_database_storage_encrypted"></a> [is\_database\_storage\_encrypted](#input\_is\_database\_storage\_encrypted) | Whether the database storage is encrypted in rest | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC to use for the RDS cluster | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_connection_endpoint"></a> [cluster\_connection\_endpoint](#output\_cluster\_connection\_endpoint) | The endpoint URL on which the database cluster is accessible |
| <a name="output_cluster_host"></a> [cluster\_host](#output\_cluster\_host) | The hostname of the database cluster |
| <a name="output_cluster_port"></a> [cluster\_port](#output\_cluster\_port) | The port on which the database cluster is waiting for client connections |
| <a name="output_database_cluster_arn"></a> [database\_cluster\_arn](#output\_database\_cluster\_arn) | The unique resource ID of the database cluster |
| <a name="output_database_cluster_id"></a> [database\_cluster\_id](#output\_database\_cluster\_id) | The unique resource ID of the database cluster |
| <a name="output_database_cluster_root_password"></a> [database\_cluster\_root\_password](#output\_database\_cluster\_root\_password) | Database root user password |
| <a name="output_database_cluster_root_user"></a> [database\_cluster\_root\_user](#output\_database\_cluster\_root\_user) | Database root user |
