variable "namespace" {
  type    = string
  default = "metallb-system"
}

variable "addresses" {
  type    = list(string)
  default = ["192.168.2.1-192.168.2.254"]
}

