resource "helm_release" "main" {
  name             = "metallb"
  namespace        = var.namespace
  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  version          = "0.13.11"
  create_namespace = true
}

resource "kubernetes_manifest" "ip_address_pool" {
  count = 1 # To disable manifest creation on first run to prevent typing issue

  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"

    metadata = {
      name      = "main"
      namespace = helm_release.main.metadata[0].namespace
    }

    spec = {
      addresses = var.addresses
    }
  }

  depends_on = [
    helm_release.main
  ]
}

resource "kubernetes_manifest" "l2_advertisement" {
  count = 1 # To disable manifest creation on first run to prevent typing issue

  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"

    metadata = {
      name      = "main"
      namespace = helm_release.main.metadata[0].namespace
    }
  }

  depends_on = [
    helm_release.main
  ]
}

