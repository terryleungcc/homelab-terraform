module "metallb" {
  source = "./applications/metallb"
}

module "ingress-nginx" {
  source = "./applications/ingress-nginx"
}

