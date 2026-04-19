variable "application_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the Application Gateway"
}

variable "app_service_fqdn" {
  type        = string
  description = "FQDN of the App Service (frontend UI)"
}

variable "backend_ip" {
  type        = string
  description = "Private IP of the backend (AKS internal LB)"
  default     = "10.1.2.250"
}

variable "appgw_nsg_assoc_id" {
  type        = string
  description = "Network Security Group Association ID for the Application Gateway"
}

variable "log_analytics_workspace_id" {
  type = string
}
