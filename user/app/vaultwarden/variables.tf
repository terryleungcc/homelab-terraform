variable "namespace" {
  type    = string
  default = "vaultwarden"
}

variable "token_path" {
  type    = string
  default = "/vaultwarden/admin/token"
}

variable "volume_capacity" {
  type    = string
  default = "128Gi"
}
