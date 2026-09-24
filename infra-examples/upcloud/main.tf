locals {
  labels = {
    environment = var.environment
    project     = "harmony"
  }
}

module "network" {
  source = "../../terraform/modules/upcloud/network"

  zone        = var.zone
  environment = var.environment
  labels      = local.labels
}

module "kubernetes_cluster" {
  source = "../../terraform/modules/upcloud/uks"

  zone               = var.zone
  environment        = var.environment
  network_id         = module.network.network_id
  cluster_name       = var.kubernetes_cluster_name
  kubernetes_version = var.kubernetes_version
  labels             = local.labels
}

module "bucket" {
  source = "../../terraform/modules/upcloud/object-storage"

  environment   = var.environment
  region        = var.object_storage_region
  bucket_prefix = var.bucket_prefix
  network_id    = module.network.network_id
  labels        = local.labels
}

module "mysql_database" {
  source = "../../terraform/modules/upcloud/mysql"

  zone                  = var.zone
  environment           = var.environment
  network_id            = module.network.network_id
  network_cidr          = module.network.network_cidr
  database_cluster_name = "${module.kubernetes_cluster.cluster_name}-mysql"
  labels                = local.labels
}

module "mongodb_database" {
  source = "../../terraform/modules/mongodb"

  environment             = var.environment
  mongodbatlas_project_id = var.mongodbatlas_project_id
  database_cluster_name   = "${module.kubernetes_cluster.cluster_name}-mongodb"
  atlas_region_name       = var.atlas_region_name
  ip_access_cidrs         = ["${module.network.gateway_public_ip}/32"]
}

resource "local_file" "kubeconfig" {
  content         = module.kubernetes_cluster.kubeconfig
  filename        = "${path.module}/kubeconfig"
  file_permission = "0600"
}
