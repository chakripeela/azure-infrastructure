variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "plan_name" {
  type = string
}
variable "subnet_id" {
  type = string
}

variable "enabled" {
  description = "Whether the app service is enabled (running)."
  type        = bool
  default     = true
}