# Cluser configurations

module "storage-class" {
  source = "./cluster/config/storage-class"
}

# Cluster applications

module "cert-manager" {
  source = "./cluster/app/cert-manager"
}

module "ingress-nginx" {
  source = "./cluster/app/ingress-nginx"
}

module "metallb" {
  source = "./cluster/app/metallb"
}

# User applications

module "vaultwarden" {
  source = "./user/app/vaultwarden"
}

