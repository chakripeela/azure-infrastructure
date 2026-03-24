output "app_service_default_hostname" {
  description = "Default FQDN of the App Service"
  value       = azurerm_linux_web_app.app.default_hostname
}
