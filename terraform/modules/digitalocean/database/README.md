## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_database_cluster.database_cluster](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_cluster) | resource |
| [digitalocean_database_db.databases](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_db) | resource |
| [digitalocean_database_firewall.database_cluster_firewall](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_firewall) | resource |
| [digitalocean_database_user.users](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_user) | resource |
| [null_resource.no_primary_key_patch_database_cluster](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [digitalocean_vpc.vpc](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_token"></a> [access\_token](#input\_access\_token) | DigitalOcean access token in order to patch the database settings. | `string` | n/a | yes |
| <a name="input_database_cluster_instance_size"></a> [database\_cluster\_instance\_size](#input\_database\_cluster\_instance\_size) | Database instance size. | `string` | `"s-1vcpu-1gb"` | no |
| <a name="input_database_cluster_instances"></a> [database\_cluster\_instances](#input\_database\_cluster\_instances) | Number of nodes in the database cluster. | `number` | `1` | no |
| <a name="input_database_engine"></a> [database\_engine](#input\_database\_engine) | Database engine name. | `string` | n/a | yes |
| <a name="input_database_engine_version"></a> [database\_engine\_version](#input\_database\_engine\_version) | Database engine version. | `string` | n/a | yes |
| <a name="input_database_maintenance_window_day"></a> [database\_maintenance\_window\_day](#input\_database\_maintenance\_window\_day) | The day when maintenance can be executed on the database cluster. | `string` | `"sunday"` | no |
| <a name="input_database_maintenance_window_time"></a> [database\_maintenance\_window\_time](#input\_database\_maintenance\_window\_time) | The hour in UTC at which maintenance updates will be applied in 24 hour format. | `string` | n/a | yes |
| <a name="input_database_users"></a> [database\_users](#input\_database\_users) | Map of overrides for the user and database names. | <pre>map(object({<br/>    username = string<br/>    database = string<br/>  }))</pre> | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The DigitalOcean project environment. (for example: production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | List of rules to apply on the related firewalls. | <pre>list(object({<br/>    type  = string<br/>    value = string<br/>  }))</pre> | n/a | yes |
| <a name="input_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#input\_kubernetes\_cluster\_name) | The name of the Kubernetes cluster. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | DigitalOcean region to create the resources in. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC to use for the Kubernetes cluster. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_connection_string"></a> [cluster\_connection\_string](#output\_cluster\_connection\_string) | The URI to use as a connection string for the database cluster. |
| <a name="output_cluster_host"></a> [cluster\_host](#output\_cluster\_host) | The hostname of the database cluster. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The unique resource ID of the database cluster. |
| <a name="output_cluster_port"></a> [cluster\_port](#output\_cluster\_port) | The port on which the database cluster is waiting for client connections. |
| <a name="output_cluster_root_password"></a> [cluster\_root\_password](#output\_cluster\_root\_password) | Database root user password |
| <a name="output_cluster_root_user"></a> [cluster\_root\_user](#output\_cluster\_root\_user) | Database root user |
| <a name="output_cluster_urn"></a> [cluster\_urn](#output\_cluster\_urn) | The unique resource ID of the database cluster. |
| <a name="output_database_user_credentials"></a> [database\_user\_credentials](#output\_database\_user\_credentials) | List of database and user credentials mapping. |
