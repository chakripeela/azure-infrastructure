variable "app_service_fqdn" {
  description = "FQDN of the App Service."
  type        = string
}

variable "backend_ip" {
  description = "Backend IP for AKS API."
  type        = string
}
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

variable "gateway_type" {
  description = "Type of gateway to deploy: appgw or frontdoor"
  type        = string
  default     = "appgw"
}
