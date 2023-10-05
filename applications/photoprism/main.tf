resource "kubernetes_namespace" "main" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "main" {
  metadata {
    name      = "photoprism"
    namespace = kubernetes_namespace.main.id
    labels = {
      "app.kubernetes.io/name" = "photoprism"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "photoprism"
      }
    }

    template {
      metadata {
        namespace = kubernetes_namespace.main.id
        labels = {
          "app.kubernetes.io/name" = "photoprism"
        }
      }

      spec {
        container {
          image = "photoprism/photoprism"
          name  = "photoprism"

          env {
            name = "PHOTOPRISM_ADMIN_USER"
	    value = "admin"
	  }

          env {
            name  = "PHOTOPRISM_ADMIN_PASSWORD"
            value = data.aws_ssm_parameter.main.value
          }

	  env {
            name = "PHOTOPRISM_SITE_URL"
	    value = "http://localhost:80/"
	  }

	  env {
            name = "PHOTOPRISM_HTTP_PORT"
	    value = 80
	  }

          port {
            container_port = 80
            protocol       = "TCP"
          }

          volume_mount {
            mount_path = "/photoprism/originals"
            name       = "photoprism-originals"
            read_only  = false
          }
          
	  volume_mount {
            mount_path = "/photoprism/storage"
            name       = "photoprism-storage"
            read_only  = false
          }
        }

        volume {
          name = "photoprism-originals"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.photoprism_originals.metadata[0].name
            read_only  = false
          }
        }
        
	volume {
          name = "photoprism-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.photoprism_storage.metadata[0].name
            read_only  = false
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "photoprism_originals" {
  metadata {
    name      = "photoprism-originals-volume"
    namespace = kubernetes_namespace.main.id
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = var.originals_volume_capacity
      }
    }

    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume_claim" "photoprism_storage" {
  metadata {
    name      = "photoprism-storage-volume"
    namespace = kubernetes_namespace.main.id
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = var.storage_volume_capacity
      }
    }

    storage_class_name = "standard"
  }
}

resource "kubernetes_service" "main" {
  metadata {
    name      = "photoprism"
    namespace = kubernetes_namespace.main.id
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "photoprism"
    }

    port {
      port     = 80
      protocol = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "main" {
  metadata {
    name      = "photoprism-ingress"
    namespace = kubernetes_namespace.main.id
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "photoprism.terentius.xyz"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "photoprism"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = ["photoprism.terentius.xyz"]
      secret_name = "photoprism-tls-secret"
    }
  }
}

data "aws_ssm_parameter" "main" {
  name = var.password_path
}

