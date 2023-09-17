# Configure cluser

module "storage-class" {
  source = "./configurations/storage-class"
}

# Deploy applications

module "cert-manager" {
  source = "./applications/cert-manager"
}

module "ingress-nginx" {
  source = "./applications/ingress-nginx"
}

module "metallb" {
  source = "./applications/metallb"
}

