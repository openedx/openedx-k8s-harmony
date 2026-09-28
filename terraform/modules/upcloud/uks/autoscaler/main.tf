terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

locals {
  labels = {
    k8s-addon = "cluster-autoscaler.addons.k8s.io"
    k8s-app   = "cluster-autoscaler"
  }

  command = concat(
    [
      "/cluster-autoscaler",
      "--cloud-provider=upcloud",
      "--stderrthreshold=info",
      "--scale-down-enabled=true",
      "--v=4",
    ],
    [
      for group in var.node_groups :
      "--nodes=${group.min_node_count}:${group.max_node_count}:${group.name}"
    ],
  )
}

resource "kubernetes_service_account_v1" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels    = local.labels
  }
}

resource "kubernetes_cluster_role_v1" "cluster_autoscaler" {
  metadata {
    name   = "cluster-autoscaler"
    labels = local.labels
  }

  rule {
    api_groups = [""]
    resources  = ["events", "endpoints"]
    verbs      = ["create", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/status"]
    verbs      = ["update"]
  }

  rule {
    api_groups     = [""]
    resources      = ["endpoints"]
    resource_names = ["cluster-autoscaler"]
    verbs          = ["get", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["watch", "list", "get"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["watch", "list", "get", "update"]
  }

  rule {
    api_groups = [""]
    resources = [
      "namespaces",
      "pods",
      "services",
      "replicationcontrollers",
      "persistentvolumeclaims",
      "persistentvolumes",
    ]
    verbs = ["watch", "list", "get"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }

  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["watch", "list"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources = [
      "storageclasses",
      "csinodes",
      "csistoragecapacities",
      "csidrivers",
      "volumeattachments",
    ]
    verbs = ["watch", "list", "get"]
  }

  rule {
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch", "patch"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create"]
  }

  rule {
    api_groups     = ["coordination.k8s.io"]
    resources      = ["leases"]
    resource_names = ["cluster-autoscaler"]
    verbs          = ["get", "update"]
  }

  rule {
    api_groups = ["resource.k8s.io"]
    resources  = ["resourceslices", "deviceclasses", "resourceclaims"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_v1" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels    = local.labels
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    resource_names = [
      "cluster-autoscaler-status",
      "cluster-autoscaler-priority-expander",
    ]
    verbs = ["delete", "get", "update", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "cluster_autoscaler" {
  metadata {
    name   = "cluster-autoscaler"
    labels = local.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.cluster_autoscaler.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.cluster_autoscaler.metadata[0].name
    namespace = "kube-system"
  }
}

resource "kubernetes_role_binding_v1" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels    = local.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.cluster_autoscaler.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.cluster_autoscaler.metadata[0].name
    namespace = "kube-system"
  }
}

resource "kubernetes_secret_v1" "upcloud_autoscaler" {
  metadata {
    name      = "upcloud-autoscaler"
    namespace = "kube-system"
  }

  data = {
    token = var.upcloud_token
  }
}

resource "kubernetes_deployment_v1" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      app = "cluster-autoscaler"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "cluster-autoscaler"
      }
    }

    template {
      metadata {
        labels = {
          app = "cluster-autoscaler"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.cluster_autoscaler.metadata[0].name
        priority_class_name  = "system-cluster-critical"

        container {
          name              = "cluster-autoscaler"
          image             = var.image
          image_pull_policy = "Always"
          command           = local.command

          env {
            name  = "UPCLOUD_CLUSTER_ID"
            value = var.cluster_id
          }

          env {
            name = "UPCLOUD_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.upcloud_autoscaler.metadata[0].name
                key  = "token"
              }
            }
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "300Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "300Mi"
            }
          }

          volume_mount {
            name       = "ssl-certs"
            mount_path = "/etc/ssl/certs/ca-certificates.crt"
            read_only  = true
          }
        }

        volume {
          name = "ssl-certs"

          host_path {
            path = "/etc/ssl/certs/ca-certificates.crt"
          }
        }
      }
    }
  }
}
