resource "azurerm_virtual_network" "vnet_frontend" {
  name                = "vnet-${var.application_name}-frontend-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "vnet_backend" {
  name                = "vnet-${var.application_name}-backend-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "appsvc_subnet" {
  name                 = "snet-appsvc-${var.application_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_frontend.name
  address_prefixes     = ["10.0.1.0/24"]
  delegation {
    name = "appservice-delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_subnet" "sql_subnet" {
  name                 = "snet-sql-${var.application_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_backend.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_security_group" "default_nsg" {
  name                = "nsg-${var.application_name}-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_database_dns_zone_backend_link" {
  name                  = "vnet-backend-sql-dns-link-${var.application_name}"
  resource_group_name   = var.shared_resource_group
  private_dns_zone_name = azurerm_private_dns_zone.sql_database_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet_backend.id
}

resource "azurerm_virtual_network_peering" "frontend_to_backend" {
  name                      = "peer-frontend-to-backend-${var.application_name}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.vnet_frontend.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_backend.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "backend_to_frontend" {
  name                      = "peer-backend-to-frontend-${var.application_name}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.vnet_backend.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_frontend.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
