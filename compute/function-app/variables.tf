variable "application_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "service_plan_id" {
  type = string
}

variable "function_app_name" {
  type    = string
  default = null
}

variable "storage_account_name" {
  type    = string
  default = null
}

variable "functions_extension_version" {
  type    = string
  default = "~4"
}

variable "node_version" {
  type    = string
  default = "20"
}

variable "app_settings" {
  type    = map(string)
  default = {}
}