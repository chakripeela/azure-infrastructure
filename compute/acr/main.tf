
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }

    azapi = {
      source = "Azure/azapi"
    }
  }
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azapi_resource" "replica" {
  for_each  = toset(var.geo_replication_locations)
  type      = "Microsoft.ContainerRegistry/registries/replications@2025-11-01"
  name      = each.value
  parent_id = azurerm_container_registry.acr.id
  location  = each.value

  body = {
    properties = {
      regionEndpointEnabled = true
    }
  }
}

resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                = "pep-${var.application_name}-acr"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.application_name}-acr"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-zone-group"
    private_dns_zone_ids = [var.acr_private_dns_zone_id]
  }
}

resource "azurerm_private_endpoint" "acr_private_endpoint_dr" {
  count               = var.dr_subnet_id != null && var.dr_acr_private_dns_zone_id != null && var.dr_location != null ? 1 : 0
  name                = "pep-${var.application_name}-acr-dr"
  location            = var.dr_location
  resource_group_name = var.dr_resource_group_name != null ? var.dr_resource_group_name : var.resource_group_name
  subnet_id           = var.dr_subnet_id

  private_service_connection {
    name                           = "psc-${var.application_name}-acr-dr"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-zone-group-dr"
    private_dns_zone_ids = [var.dr_acr_private_dns_zone_id]
  }
}