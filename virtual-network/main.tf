resource "azurerm_virtual_network" "virtual_network" {
  name                = "vnet-${var.application_name}-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "shared_subnet" {
  name                 = "snet-shared-${var.application_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_network_security_group" "default_nsg" {
  name                = "nsg-${var.application_name}-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
}
