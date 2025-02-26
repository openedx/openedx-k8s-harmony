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
| [digitalocean_spaces_bucket.spaces_bucket](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/spaces_bucket) | resource |
| [digitalocean_spaces_bucket_cors_configuration.spaces_bucket_policy](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/spaces_bucket_cors_configuration) | resource |
| [digitalocean_spaces_bucket_policy.public_root_object_policy](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/spaces_bucket_policy) | resource |
| [random_id.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cors_origins"></a> [allowed\_cors\_origins](#input\_allowed\_cors\_origins) | Lists the CORS origins to allow CORS requests from. | `list(string)` | <pre>[<br/>  "*"<br/>]</pre> | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | The prefix for the DigitalOcean spaces bucket for easier identification. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The DigitalOcean project environment. (for example: production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_is_force_destroy_enabled"></a> [is\_force\_destroy\_enabled](#input\_is\_force\_destroy\_enabled) | Determines if the DigitalOcean spaces bucket is force-destroyed or not upon deletion. | `bool` | `true` | no |
| <a name="input_is_public"></a> [is\_public](#input\_is\_public) | Determines whether the DigitalOcean spaces bucket's root object is publicly available or not. | `bool` | `false` | no |
| <a name="input_is_versioning_enabled"></a> [is\_versioning\_enabled](#input\_is\_versioning\_enabled) | Determines if versioning is allowed on the DigitalOcean spaces bucket or not. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | DigitalOcean region to create the resources in. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | The ID of the bucket that is generated during creation. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name of the bucket, including the generated suffix. |
| <a name="output_bucket_urn"></a> [bucket\_urn](#output\_bucket\_urn) | The unique resource ID of the bucket. |
