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
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [upcloud_managed_object_storage.this](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/resources/managed_object_storage) | resource |
| [upcloud_managed_object_storage_bucket.this](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/resources/managed_object_storage_bucket) | resource |
| [upcloud_managed_object_storage_user.this](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/resources/managed_object_storage_user) | resource |
| [upcloud_managed_object_storage_user_access_key.this](https://registry.terraform.io/providers/UpCloudLtd/upcloud/latest/docs/resources/managed_object_storage_user_access_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | Prefix for the bucket name. The module lowercases it and appends the environment and a random suffix. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The UpCloud project environment. (for example: production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to the Managed Object Storage service. | `map(string)` | `{}` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | Optional private network UUID. When set, the service is attached to that network and to a public endpoint. | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | Object storage region, for example europe-1. This is not a compute zone. The private network zone must belong to this region. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_access_key_id"></a> [access\_key\_id](#output\_access\_key\_id) | Access key ID for the openedx object storage user. |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | ID of the bucket, in {service UUID}/{bucket name} form. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the bucket. |
| <a name="output_endpoint_hostname"></a> [endpoint\_hostname](#output\_endpoint\_hostname) | Public S3 endpoint hostname. |
| <a name="output_secret_access_key"></a> [secret\_access\_key](#output\_secret\_access\_key) | Secret access key for the openedx object storage user. |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | UUID of the Managed Object Storage service. |
