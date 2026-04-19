resource "azurerm_log_analytics_workspace" "workspace" {
  name                = coalesce(var.workspace_name, "${var.resource_group_name}-law")
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_in_days
}

resource "azurerm_application_insights" "app_insights" {
  name                = coalesce(var.app_insights_name, "${var.resource_group_name}-ai")
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.workspace.id
  retention_in_days   = var.app_insights_retention_in_days
}