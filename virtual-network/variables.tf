
variable "application_name" {
  description = "Name of the application."
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources."
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "shared_resource_group" {
  type = string
}
