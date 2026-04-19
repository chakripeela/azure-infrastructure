output "workspace_id" {
  value = azurerm_log_analytics_workspace.workspace.id
}

output "workspace_name" {
  value = azurerm_log_analytics_workspace.workspace.name
}

output "app_insights_id" {
  value = azurerm_application_insights.app_insights.id
}

output "app_insights_name" {
  value = azurerm_application_insights.app_insights.name
}
