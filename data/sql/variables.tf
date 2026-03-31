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
  type = string
}

variable "sql_private_dns_zone_id" {
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

variable "enable_failover_group" {
  type    = bool
  default = false
}
variable "dr_sql_server_id" {
  type    = string
  default = ""
  description = "Resource ID of the DR region SQL server."
}
