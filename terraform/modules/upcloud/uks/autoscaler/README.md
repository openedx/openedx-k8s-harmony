# UKS Cluster Autoscaler

Installs [UpCloud’s fork of Cluster Autoscaler](https://github.com/UpCloudLtd/autoscaler/tree/feat/cluster-autoscaler-cloudprovider-upcloud/cluster-autoscaler/cloudprovider/upcloud) into an existing UKS cluster.

UKS node groups have no minimum or maximum. This module passes one `--nodes=<min>:<max>:<name>` argument for every group. A minimum of 1 is required: the autoscaler needs a live node in each group, and a group left at zero can stop scaling for the whole cluster.

The default image is `ghcr.io/upcloudltd/autoscaler:v1.29.5`. Keep that UpCloud image. The upstream Cluster Autoscaler does not include an UpCloud cloud provider.

The Kubernetes provider has to be configured by the caller. It cannot be configured inside the UKS module from the cluster that module creates.

```hcl
module "cluster_autoscaler" {
  source = "../../terraform/modules/upcloud/uks/autoscaler"

  cluster_id    = module.kubernetes_cluster.cluster_id
  upcloud_token = var.upcloud_token
  node_groups   = module.kubernetes_cluster.node_groups
}
```

`upcloud_token` is stored in the `kube-system/upcloud-autoscaler` Secret. Prefer a token that can manage only this cluster. The token is in Terraform state.
