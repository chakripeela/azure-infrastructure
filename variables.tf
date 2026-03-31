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