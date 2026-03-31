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
variable "is_dr" {
  type    = bool
  default = false
}