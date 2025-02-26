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
| [aws_kms_key.s3_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.s3_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.s3_cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.s3_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_public_access_block.s3_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.s3_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.s3_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [random_id.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cors_origins"></a> [allowed\_cors\_origins](#input\_allowed\_cors\_origins) | Lists the CORS origins to allow CORS requests from. | `list(string)` | <pre>[<br/>  "*"<br/>]</pre> | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | The prefix for the AWS s3 bucket for easier identification. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The AWS project environment. (for example: production, staging, development, etc.) | `string` | n/a | yes |
| <a name="input_is_force_destroy_enabled"></a> [is\_force\_destroy\_enabled](#input\_is\_force\_destroy\_enabled) | Determines if the AWS s3 bucket is force-destroyed or not upon deletion. | `bool` | `true` | no |
| <a name="input_is_public"></a> [is\_public](#input\_is\_public) | Determines whether the AWS s3 bucket's root object is publicly available or not. | `bool` | `false` | no |
| <a name="input_is_versioning_enabled"></a> [is\_versioning\_enabled](#input\_is\_versioning\_enabled) | Determines if versioning is allowed on the AWS s3 bucket or not. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The unique resource ID of the bucket. |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | The domain name of the bucket, including the generated prefix. |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | The ID of the bucket that is generated during creation. |
