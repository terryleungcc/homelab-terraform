# Configure cluser

module "storage-class" {
  source = "./configurations/storage-class"
}

# Deploy applications

module "metallb" {
  source = "./applications/metallb"
}

module "ingress-nginx" {
  source = "./applications/ingress-nginx"
}

