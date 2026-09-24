## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_upcloud"></a> [upcloud](#provider\_upcloud) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [random_password.database_user](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [upcloud_managed_database_logical_database.databases](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/resources/managed_database_logical_database) | resource |
| [upcloud_managed_database_mysql.this](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/resources/managed_database_mysql) | resource |
| [upcloud_managed_database_user.users](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/resources/managed_database_user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_database_cluster_name"></a> [database\_cluster\_name](#input\_database\_cluster\_name) | Service name and hostname prefix. Must be unique in the account. | `string` | n/a | yes |
| <a name="input_database_users"></a> [database\_users](#input\_database\_users) | Additional logical databases and users. Keys are arbitrary; username and database set the created names. | <pre>map(object({<br/>    username = string<br/>    database = string<br/>  }))</pre> | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The UpCloud project environment. (for example: production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to the MySQL service. | `map(string)` | `{}` | no |
| <a name="input_maintenance_window_dow"></a> [maintenance\_window\_dow](#input\_maintenance\_window\_dow) | Maintenance window day of week, in lowercase. | `string` | `"sunday"` | no |
| <a name="input_maintenance_window_time"></a> [maintenance\_window\_time](#input\_maintenance\_window\_time) | Maintenance window UTC time in hh:mm:ss format. | `string` | `"01:00:00"` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | CIDR allowed to connect to MySQL. Public access is disabled. | `string` | n/a | yes |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | UUID of the private network to attach. | `string` | n/a | yes |
| <a name="input_plan"></a> [plan](#input\_plan) | Managed MySQL plan. List plans with `upctl database plans mysql`. | `string` | `"1x1xCPU-2GB-25GB"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | UpCloud zone for the database. Must match the private network zone. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_connection_endpoint"></a> [cluster\_connection\_endpoint](#output\_cluster\_connection\_endpoint) | Connection URI of the MySQL service. |
| <a name="output_cluster_host"></a> [cluster\_host](#output\_cluster\_host) | Hostname of the MySQL service. |
| <a name="output_cluster_port"></a> [cluster\_port](#output\_cluster\_port) | Port of the MySQL service. |
| <a name="output_database_cluster_id"></a> [database\_cluster\_id](#output\_database\_cluster\_id) | UUID of the MySQL service. |
| <a name="output_database_cluster_root_password"></a> [database\_cluster\_root\_password](#output\_database\_cluster\_root\_password) | Primary MySQL password. |
| <a name="output_database_cluster_root_user"></a> [database\_cluster\_root\_user](#output\_database\_cluster\_root\_user) | Primary MySQL username. |
| <a name="output_database_user_credentials"></a> [database\_user\_credentials](#output\_database\_user\_credentials) | Additional database users and their passwords. |
