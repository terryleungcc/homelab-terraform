resource "helm_release" "main" {
  name             = "ingress-nginx"
  namespace        = var.namespace
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.7.2"
  create_namespace = true
}

