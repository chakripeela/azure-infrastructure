variable application_name {
  default="todo-app"
  type = string
}
variable "location" {
  type = string
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