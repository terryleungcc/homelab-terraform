variable "namespace" {
  type    = string
  default = "photoprism"
}

variable "password_path" {
  type    = string
  default = "/photoprism/admin/password"
}

variable "originals_volume_capacity" {
  type    = string
  default = "3Ti"
}

variable "storage_volume_capacity" {
  type = string
  default = "128Gi"
}

