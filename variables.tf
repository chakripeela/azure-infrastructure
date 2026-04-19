variable "application_name" {
  description = "Name of the application."
  type        = string
  default     = "todo-app"
}

variable "location" {
  description = "Azure region to deploy resources."
  type        = string
  default     = "centralus"
}

variable "dr_location" {
  description = "Azure region for DR deployment."
  type        = string
  default     = "eastus"
}

variable "sql_location" {
  description = "Azure region for the primary SQL server. If null, the main deployment location is used."
  type        = string
  default     = null
}

variable "sql_dr_location" {
  description = "Azure region for the DR SQL server. If null, the DR deployment location is used."
  type        = string
  default     = null
}

variable "sql_server_name" {
  type = string
}

variable "sql_database_name" {
  type = string
}

variable "sql_aad_admin_login" {
  type        = string
  description = "Display name of the Azure AD user or group to set as SQL Server admin."
}

variable "sql_aad_admin_object_id" {
  type        = string
  description = "Object ID of the Azure AD user or group to set as SQL Server admin."
}

variable "is_dr" {
  type        = bool
  description = "Enable DR region deployment (true/false)."
  default     = false
}

variable "dr_app_service_enabled" {
  type        = bool
  description = "Whether the DR App Service should remain enabled and running."
  default     = false
}

variable "log_analytics_retention_in_days" {
  type        = number
  description = "Retention period for Log Analytics workspace data."
  default     = 30
}

variable "application_insights_retention_in_days" {
  type        = number
  description = "Retention period for Application Insights data."
  default     = 90
}

variable "aks_api_internal_ip" {
  type        = string
  description = "Internal IP address of the AKS API LoadBalancer service."
  default     = "10.1.2.250"
}