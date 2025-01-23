## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_vpc.vpc](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/vpc) | resource |
| [random_id.vpc_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The DigitalOcean project environment. (for example: production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | DigitalOcean region to create the resources in. | `string` | n/a | yes |
| <a name="input_vpc_ip_range"></a> [vpc\_ip\_range](#input\_vpc\_ip\_range) | IP range assigned to the VPC. | `string` | `"10.10.0.0/24"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Optional custom name for the VPC. If not provided, a name will be generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC that is generated during creation. |
| <a name="output_vpc_ip_range"></a> [vpc\_ip\_range](#output\_vpc\_ip\_range) | The IP range that is covered by the VPC. |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The name of the VPC, including the generated suffix, if any. |
| <a name="output_vpc_urn"></a> [vpc\_urn](#output\_vpc\_urn) | The unique resource ID of the VPC. |
