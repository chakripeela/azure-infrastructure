resource "azurerm_service_plan" "plan" {
  name                = var.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
    sku_name            = "B1"
}

resource "azurerm_linux_web_app" "app" {
  name                      = "todo-app-ui"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  service_plan_id           = azurerm_service_plan.plan.id
  virtual_network_subnet_id = var.subnet_id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = "22-lts"
    }
    vnet_route_all_enabled = true
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "API_BASE_URL"                        = "http://10.1.2.250"
  }
  enabled = var.enabled
}
