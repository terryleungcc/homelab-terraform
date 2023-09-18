resource "kubernetes_namespace" "main" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "main" {
  metadata {
    name      = "vaultwarden"
    namespace = kubernetes_namespace.main.id
    labels = {
      "app.kubernetes.io/name" = "vaultwarden"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "vaultwarden"
      }
    }

    template {
      metadata {
        namespace = kubernetes_namespace.main.id
        labels = {
          "app.kubernetes.io/name" = "vaultwarden"
        }
      }

      spec {
        container {
          image = "vaultwarden/server"
          name  = "vaultwarden"

          env {
            name  = "ADMIN_TOKEN"
            value = data.aws_ssm_parameter.main.value
          }

          port {
            container_port = 80
            protocol       = "TCP"
          }

          volume_mount {
            mount_path = "/data"
            name       = "vaultwarden-data"
            read_only  = false
          }
        }

        volume {
          name = "vaultwarden-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.main.metadata[0].name
            read_only  = false
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "main" {
  metadata {
    name      = "vaultwarden-persistent-volume-claim"
    namespace = kubernetes_namespace.main.id
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "8Gi"
      }
    }

    storage_class_name = "storage-class-nfs"
  }
}

resource "kubernetes_service" "main" {
  metadata {
    name      = "vaultwarden"
    namespace = kubernetes_namespace.main.id
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "vaultwarden"
    }

    port {
      port     = 80
      protocol = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "main" {
  metadata {
    name      = "vaultwarden-ingress"
    namespace = kubernetes_namespace.main.id
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "vaultwarden.terentius.xyz"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "vaultwarden"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = ["vaultwarden.terentius.xyz"]
      secret_name = "vaultwarden-tls-secret"
    }
  }
}

data "aws_ssm_parameter" "main" {
  name = var.token_path
}

