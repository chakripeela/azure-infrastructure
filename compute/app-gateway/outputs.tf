output "appgw_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.appgw_pip.ip_address
}

output "appgw_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}
