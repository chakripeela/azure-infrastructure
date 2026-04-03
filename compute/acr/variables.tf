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
  type = string
}

variable "acr_private_dns_zone_id" {
  type = string
}

variable "geo_replication_locations" {
  type    = list(string)
  default = []
}

variable "dr_location" {
  type    = string
  default = null
}

variable "dr_resource_group_name" {
  type    = string
  default = null
}

variable "dr_subnet_id" {
  type    = string
  default = null
}

variable "dr_acr_private_dns_zone_id" {
  type    = string
  default = null
}