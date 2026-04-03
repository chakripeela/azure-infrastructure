variable "acr_name" {
  type = string
  default = "chakripeelaacr"
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}

variable "application_name" {
  type = string
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "acr_private_dns_zone_id" {
  type    = string
  default = null
}