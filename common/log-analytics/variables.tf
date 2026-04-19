variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "workspace_name" {
  type    = string
  default = null
}

variable "app_insights_name" {
  type    = string
  default = null
}

variable "log_analytics_retention_in_days" {
  type    = number
  default = 30
}

variable "app_insights_retention_in_days" {
  type    = number
  default = 90
}