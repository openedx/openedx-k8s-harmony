data "digitalocean_kubernetes_versions" "available_versions" {}

module "main_vpc" {
  source = "../../terraform/modules/digitalocean/vpc"

  region = var.region
  environment = var.environment
}

module "kubernetes_cluster" {
  source = "../../terraform/modules/digitalocean/doks"

  region = var.region
  environment = var.environment
  vpc_id = module.main_vpc.vpc_id

  cluster_name = var.kubernetes_cluster_name
  kubernetes_version = data.digitalocean_kubernetes_versions.available_versions.latest_version
}

module "spaces" {
  source = "../../terraform/modules/digitalocean/spaces"

  region = var.region
  environment = var.environment

  bucket_prefix = "my-institute"
}

module "mysql_database" {
  source = "../../terraform/modules/digitalocean/database"

  region = var.region
  environment = var.environment
  access_token = var.do_access_token
  vpc_id = module.main_vpc.vpc_id
  kubernetes_cluster_name = var.kubernetes_cluster_name

  database_engine = "mysql"
  database_engine_version = 8
  database_cluster_instances = 1
  database_cluster_instance_size = "db-s-1vcpu-1gb"
  database_maintenance_window_day = "sunday"
  database_maintenance_window_time = "01:00:00"

  # Database cluster firewalls cannot use VPC CIDR, therefore the access is
  # limited to the k8s cluster
  firewall_rules = [
    {
      type  = "k8s"
      value = module.kubernetes_cluster.cluster_id
    },
  ]
}

module "mongodb_database" {
  source = "../../terraform/modules/digitalocean/database"

  region = var.region
  environment = var.environment
  access_token = var.do_access_token
  vpc_id = module.main_vpc.vpc_id
  kubernetes_cluster_name = var.kubernetes_cluster_name

  database_engine = "mongodb"
  database_engine_version = 7
  database_cluster_instances = 3
  database_cluster_instance_size = "db-s-1vcpu-1gb"
  database_maintenance_window_day = "sunday"
  database_maintenance_window_time = "1:00"

  # Database cluster firewalls cannot use VPC CIDR, therefore the access is
  # limited to the k8s cluster
  firewall_rules = [
    {
      type  = "k8s"
      value = module.kubernetes_cluster.cluster_id
    },
  ]
}

resource "digitalocean_project" "project" {
  name        = var.kubernetes_cluster_name
  description = "Open edX deployment using Harmony"
  purpose     = "Web Application"

  resources = [
    module.kubernetes_cluster.cluster_urn,
    module.spaces.bucket_urn,
    module.mysql_database.cluster_urn,
    module.mongodb_database.cluster_urn,
  ]
}
