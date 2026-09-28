## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.62 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | ~> 2.17 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.62 |
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | ~> 2.17 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_route.peeraccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_vpc_peering_connection_accepter.accept_mongo_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [mongodbatlas_network_container.cluster_network_container](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/network_container) | resource |
| [mongodbatlas_network_peering.cluster_network_peering](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/network_peering) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_atlas_cidr_block"></a> [atlas\_cidr\_block](#input\_atlas\_cidr\_block) | CIDR block Atlas uses for the peered network container. | `string` | n/a | yes |
| <a name="input_atlas_project_id"></a> [atlas\_project\_id](#input\_atlas\_project\_id) | The ID of the MongoDB Atlas project. | `string` | n/a | yes |
| <a name="input_atlas_region_name"></a> [atlas\_region\_name](#input\_atlas\_region\_name) | Atlas region name, for example US\_EAST\_1. Callers pass the AWS region with hyphens replaced by underscores and uppercased. | `string` | n/a | yes |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS account ID that owns the VPC. | `string` | n/a | yes |
| <a name="input_private_route_table_ids"></a> [private\_route\_table\_ids](#input\_private\_route\_table\_ids) | Private route table IDs that should route to the Atlas peering connection. | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region of the VPC. Used as the peering accepter region. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC to peer with the Atlas network container. | `string` | n/a | yes |

## Outputs

No outputs.
