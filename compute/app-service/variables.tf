variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "plan_name" {
  type = string
}

variable "service_plan_sku_name" {
  description = "App Service plan SKU shared by the web app and function app when reused."
  type        = string
  default     = "B1"
}

variable "subnet_id" {
  type = string
}

variable "enabled" {
  description = "Whether the app service is enabled (running)."
  type        = bool
  default     = true
}