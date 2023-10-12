resource "helm_release" "main" {
  name             = "cert-manager"
  namespace        = var.namespace
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.13.0"
  create_namespace = "true"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_manifest" "cluster_issuer_prod" {
  count = 1 # To disable manifest creation on first run to prevent typing issue

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = "letsencrypt-prod"
    }

    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "terry.leung.cc@proton.me"

        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }

        solvers = [
          {
            http01 = {
              ingress = {
                ingressClassName = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "cluster_issuer_staging" {
  count = 1 # To disable manifest creation on first run to prevent typing issue

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = "letsencrypt-staging"
    }

    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = "terry.leung.cc@proton.me"

        privateKeySecretRef = {
          name = "letsencrypt-staging"
        }

        solvers = [
          {
            http01 = {
              ingress = {
                ingressClassName = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}

