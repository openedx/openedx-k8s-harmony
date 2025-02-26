## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_kubernetes_cluster.cluster](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_cluster) | resource |
| [digitalocean_kubernetes_node_pool.additional_node_pools](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_node_pool) | resource |
| [digitalocean_tag.worker_firewall](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/tag) | resource |
| [digitalocean_vpc.vpc](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_node_pools"></a> [additional\_node\_pools](#input\_additional\_node\_pools) | Additional node pools attached to the cluster. | <pre>list(object({<br/>    name           = string<br/>    size           = string<br/>    min_node_count = number<br/>    max_node_count = number<br/>    labels         = optional(map(any))<br/>  }))</pre> | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the Kubernetes cluster. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The DigitalOcean project environment. (for example: production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_is_auto_scaling_enabled"></a> [is\_auto\_scaling\_enabled](#input\_is\_auto\_scaling\_enabled) | Whether auto scaling is enabled for the cluster or not. | `bool` | n/a | yes |
| <a name="input_is_auto_upgrade_enabled"></a> [is\_auto\_upgrade\_enabled](#input\_is\_auto\_upgrade\_enabled) | Whether auto upgrade is enabled for the cluster or not. | `bool` | n/a | yes |
| <a name="input_is_surge_upgrade_enabled"></a> [is\_surge\_upgrade\_enabled](#input\_is\_surge\_upgrade\_enabled) | Whether surge upgrade is enabled for the cluster or not. | `bool` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The supported Kubernetes version to install for the cluster. | `string` | n/a | yes |
| <a name="input_max_worker_node_count"></a> [max\_worker\_node\_count](#input\_max\_worker\_node\_count) | Maximum number of running Kubernetes worker nodes. | `number` | `5` | no |
| <a name="input_min_worker_node_count"></a> [min\_worker\_node\_count](#input\_min\_worker\_node\_count) | Minimum number of running Kubernetes worker nodes. | `number` | `3` | no |
| <a name="input_region"></a> [region](#input\_region) | DigitalOcean region to create the resources in. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC to use for the Kubernetes cluster. | `string` | n/a | yes |
| <a name="input_worker_node_size"></a> [worker\_node\_size](#input\_worker\_node\_size) | Kubernetes worker node size. | `string` | `"s-2vcpu-4gb"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint of the Kubernetes cluster. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID of the Kubernetes cluster that is generated during creation. |
| <a name="output_cluster_ipv4"></a> [cluster\_ipv4](#output\_cluster\_ipv4) | IPv4 address of the Kubernetes cluster. |
| <a name="output_cluster_urn"></a> [cluster\_urn](#output\_cluster\_urn) | The unique resource ID of the Kubernetes cluster. |
