# UpCloud infrastructure example

This example creates a private network, a UKS cluster, Managed Object Storage, Managed MySQL, and a MongoDB Atlas cluster. It is a starting point, not a production layout.

UpCloud does not sell managed MongoDB. The Atlas cluster is hosted on AWS in `atlas_region_name` and allows only the NAT gateway public address. There is no VPC peering. Use `EU_CENTRAL_1` when the UpCloud zone is `de-fra1`.

Object storage buckets created here do not get CORS, versioning, or a public object policy. The UpCloud bucket resource does not support those settings.

## Credentials

Set `UPCLOUD_TOKEN`, or set the sensitive variable `upcloud_token` in `secrets.auto.tfvars` (that filename is gitignored).

Set `MONGODB_ATLAS_PUBLIC_KEY` and `MONGODB_ATLAS_PRIVATE_KEY`, or set `mongodbatlas_public_key` and `mongodbatlas_private_key` in the same file.

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
mongodbatlas_project_id = "atlas-project-id"
atlas_region_name       = "EU_CENTRAL_1"
```

```sh
export UPCLOUD_TOKEN="your-token"
export MONGODB_ATLAS_PUBLIC_KEY="your-public-key"
export MONGODB_ATLAS_PRIVATE_KEY="your-private-key"

cd infra-examples/upcloud
tofu init
tofu apply
```

`tofu apply` writes `infra-examples/upcloud/kubeconfig`. That file and the OpenTofu state contain cluster and database credentials.

```sh
export KUBECONFIG="$(pwd)/kubeconfig"
```

Run `tofu destroy` in `infra-examples/upcloud` when you are finished. The default sizes (`dev-md`, gateway plan `development`, MySQL `1x1xCPU-2GB-25GB`, Atlas `M10`) are still billable.
