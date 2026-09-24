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
| [random_id.network_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [upcloud_gateway.this](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/resources/gateway) | resource |
| [upcloud_network.this](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/resources/network) | resource |
| [upcloud_router.this](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/resources/router) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Create a NAT gateway and advertise it as the DHCP default route. Required for private UKS node groups. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The UpCloud project environment. (for example: production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_gateway_plan"></a> [gateway\_plan](#input\_gateway\_plan) | NAT gateway plan. List plans with `upctl gateway plans`. | `string` | `"development"` | no |
| <a name="input_ip_network_address"></a> [ip\_network\_address](#input\_ip\_network\_address) | IPv4 CIDR of the single SDN subnet. UpCloud allows one ip\_network per network. | `string` | `"10.0.0.0/24"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to the router, network, and gateway. | `map(string)` | `{}` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Name of the private network. Empty generates open-edx-<environment>-<suffix>. | `string` | `""` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | UpCloud zone for the private network and NAT gateway, for example de-fra1. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_gateway_id"></a> [gateway\_id](#output\_gateway\_id) | UUID of the NAT gateway. Null when the gateway is disabled. |
| <a name="output_gateway_public_ip"></a> [gateway\_public\_ip](#output\_gateway\_public\_ip) | Public IPv4 address of the NAT gateway. Null when the gateway is disabled. |
| <a name="output_network_cidr"></a> [network\_cidr](#output\_network\_cidr) | CIDR of the private network. |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | UUID of the private network. |
| <a name="output_router_id"></a> [router\_id](#output\_router\_id) | UUID of the router attached to the private network. |
