# DigitalOcean Infrastructure Example

This is an example implementation to create a production grade infrastructure for hosting Open edX instances on DigitalOcean, using the Terraform modules provided by Harmony.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | >=2.45 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.16 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >=1.17 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >=2.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.45.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kubernetes_cluster"></a> [kubernetes\_cluster](#module\_kubernetes\_cluster) | ../../terraform/modules/digitalocean/doks | n/a |
| <a name="module_main_vpc"></a> [main\_vpc](#module\_main\_vpc) | ../../terraform/modules/digitalocean/vpc | n/a |
| <a name="module_mongodb_database"></a> [mongodb\_database](#module\_mongodb\_database) | ../../terraform/modules/digitalocean/database | n/a |
| <a name="module_mysql_database"></a> [mysql\_database](#module\_mysql\_database) | ../../terraform/modules/digitalocean/database | n/a |
| <a name="module_spaces"></a> [spaces](#module\_spaces) | ../../terraform/modules/digitalocean/spaces | n/a |

## Resources

| Name | Type |
|------|------|
| [digitalocean_database_db.forum_database](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_db) | resource |
| [digitalocean_project.project](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/project) | resource |
| [digitalocean_kubernetes_cluster.cluster](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/kubernetes_cluster) | data source |
| [digitalocean_kubernetes_versions.available_versions](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/kubernetes_versions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_do_access_token"></a> [do\_access\_token](#input\_do\_access\_token) | DitialOcean access token. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The DigitalOcean project environment. | `string` | n/a | yes |
| <a name="input_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#input\_kubernetes\_cluster\_name) | Name of the DigitalOcean Kubernetes cluster to create. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | DigitalOcean region to create the resources in. | `string` | n/a | yes |

## Outputs

No outputs.
