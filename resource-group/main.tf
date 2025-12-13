resource "azurerm_resource_group" "resource_group" {
  name = "rg-${var.application_name}-${var.location}"
  location = var.location
}