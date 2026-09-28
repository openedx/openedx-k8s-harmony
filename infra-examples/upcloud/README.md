# UpCloud infrastructure example

This example creates a private network, a UKS cluster, Managed Object Storage, Managed MySQL, and a MongoDB Atlas cluster. It is a starting point, not a production layout.

UpCloud does not sell managed MongoDB. The Atlas cluster is hosted on AWS in `atlas_region_name` and allows only the NAT gateway public address. There is no VPC peering. Use `EU_CENTRAL_1` when the UpCloud zone is `de-fra1`.

Object storage buckets created here do not get CORS, versioning, or a public object policy. The UpCloud bucket resource does not support those settings.

## Credentials

Set `UPCLOUD_TOKEN`, or set the sensitive variable `upcloud_token` in `secrets.auto.tfvars` (that filename is gitignored). Cluster Autoscaler copies that token into a `kube-system` Secret, so the token has to be a Terraform value (`upcloud_token`, `TF_VAR_upcloud_token`, or `upcloud_autoscaler_token`). The provider's `UPCLOUD_TOKEN` environment variable is not copied into the cluster. Prefer `upcloud_autoscaler_token` from an account that can manage only this cluster.

The workers group starts at 3 nodes and Cluster Autoscaler may resize it from 1 to 5. Set `worker_node_min_count` and `worker_node_max_count` to change that range. Do not set a minimum of 0. The autoscaler image is UpCloud's fork, `ghcr.io/upcloudltd/autoscaler:v1.29.5`.

Set `MONGODB_ATLAS_PUBLIC_API_KEY` and `MONGODB_ATLAS_PRIVATE_API_KEY`, or set `atlas_public_key` and `atlas_private_key` in the same file. Do not pass Service Account `client_id` / `client_secret` values into those variables; Atlas then attempts OAuth2 and fails with `invalid_client`.

The private network zone must belong to `object_storage_region`. `de-fra1` belongs to `europe-1`.

## Apply

Create `infra-examples/upcloud/secrets.auto.tfvars`:

```hcl
zone                    = "de-fra1"
object_storage_region   = "europe-1"
environment             = "development"
kubernetes_cluster_name = "harmony-test"
kubernetes_version      = "1.32" # replace with a version from: upctl kubernetes versions
bucket_prefix           = "my-institute"
atlas_project_id        = "atlas-project-id"
atlas_region_name       = "EU_CENTRAL_1"
upcloud_token           = "your-token"
```

```sh
export MONGODB_ATLAS_PUBLIC_API_KEY="your-public-key"
export MONGODB_ATLAS_PRIVATE_API_KEY="your-private-key"

cd infra-examples/upcloud
tofu init
tofu apply
```

`tofu apply` writes `infra-examples/upcloud/kubeconfig`. That file and the OpenTofu state contain cluster and database credentials.

```sh
export KUBECONFIG="$(pwd)/kubeconfig"
```

Run `tofu destroy` in `infra-examples/upcloud` when you are finished. The default sizes (`dev-md`, gateway plan `development`, MySQL `1x1xCPU-2GB-25GB`, Atlas `M10`) are still billable.
