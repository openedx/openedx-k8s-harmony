# UpCloud Kubernetes Service

Creates a UKS cluster and node groups. Node groups do not have a minimum or maximum in the UpCloud API. `node_count` is the initial size, and Terraform ignores later changes so Cluster Autoscaler can resize the group.

Install the autoscaler with `terraform/modules/upcloud/uks/autoscaler`. Give every group a range whose minimum is at least 1. The default workers group starts at 3 nodes and may scale from 1 to 5. The autoscaler image is UpCloud's fork, `ghcr.io/upcloudltd/autoscaler:v1.29.5`.

## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_upcloud"></a> [upcloud](#provider\_upcloud) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [upcloud_kubernetes_cluster.cluster](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/resources/kubernetes_cluster) | resource |
| [upcloud_kubernetes_node_group.additional](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/resources/kubernetes_node_group) | resource |
| [upcloud_kubernetes_node_group.workers](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/resources/kubernetes_node_group) | resource |
| [upcloud_kubernetes_cluster.cluster](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/data-sources/kubernetes_cluster) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_additional_node_pools"></a> [additional\_node\_pools](#input\_additional\_node\_pools) | Extra node groups. Each name must be unique in the cluster and must not be "workers". min\_node\_count and max\_node\_count are the autoscaler range. | <pre>list(object({<br/>    name           = string<br/>    plan           = string<br/>    node_count     = number<br/>    min_node_count = optional(number, 1)<br/>    max_node_count = optional(number, 5)<br/>    labels         = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name prefix. The module appends the environment, and the result must be unique in the account. | `string` | n/a | yes |
| <a name="input_control_plane_ip_filter"></a> [control\_plane\_ip\_filter](#input\_control\_plane\_ip\_filter) | CIDRs allowed to reach the cluster API. Does not restrict node groups or exposed services. | `set(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The UpCloud project environment. (for example: production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes minor version, for example 1.32. List supported versions with `upctl kubernetes versions`. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to the cluster and node groups. | `map(string)` | `{}` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | UUID of the private network the cluster runs in. | `string` | n/a | yes |
| <a name="input_plan"></a> [plan](#input\_plan) | UKS control plane plan. List plans with `upctl kubernetes plans`. Use a production plan for real clusters. | `string` | `"dev-md"` | no |
| <a name="input_private_node_groups"></a> [private\_node\_groups](#input\_private\_node\_groups) | Place node groups on the private network. Requires a NAT gateway on that network. | `bool` | `true` | no |
| <a name="input_storage_encryption"></a> [storage\_encryption](#input\_storage\_encryption) | Default node storage encryption. Valid values are data-at-rest and none. Null uses the provider default. | `string` | `null` | no |
| <a name="input_worker_node_count"></a> [worker\_node\_count](#input\_worker\_node\_count) | Initial number of nodes in the default worker group. Cluster Autoscaler may change this later between worker\_node\_min\_count and worker\_node\_max\_count. | `number` | `3` | no |
| <a name="input_worker_node_max_count"></a> [worker\_node\_max\_count](#input\_worker\_node\_max\_count) | Maximum size Cluster Autoscaler may apply to the workers group. | `number` | `5` | no |
| <a name="input_worker_node_min_count"></a> [worker\_node\_min\_count](#input\_worker\_node\_min\_count) | Minimum size Cluster Autoscaler may apply to the workers group. Must be at least 1. | `number` | `1` | no |
| <a name="input_worker_node_plan"></a> [worker\_node\_plan](#input\_worker\_node\_plan) | Server plan for the default worker node group. List plans with `upctl server plans`. | `string` | `"2xCPU-4GB"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | UpCloud zone for the cluster. Must match the private network zone. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate) | PEM client certificate for the Kubernetes API. |
| <a name="output_client_key"></a> [client\_key](#output\_client\_key) | PEM client key for the Kubernetes API. |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | PEM certificate authority for the Kubernetes API. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | URI of the Kubernetes API. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | UUID of the Kubernetes cluster. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the Kubernetes cluster. |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubeconfig for the cluster. Contains client credentials. |
| <a name="output_node_groups"></a> [node\_groups](#output\_node\_groups) | Node groups and the size range Cluster Autoscaler may apply to each one. |
