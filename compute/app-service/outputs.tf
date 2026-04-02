output "app_service_default_hostname" {
  description = "Default FQDN of the App Service"
  value       = azurerm_linux_web_app.app.default_hostname
}

output "app_service_plan_id" {
  description = "ID of the shared App Service plan"
  value       = azurerm_service_plan.plan.id
}
