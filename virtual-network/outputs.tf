output "vnet_frontend_id" {
  value = azurerm_virtual_network.vnet_frontend.id
}

output "vnet_backend_id" {
  value = azurerm_virtual_network.vnet_backend.id
}

output "subnet_appsvc_id" {
  value = azurerm_subnet.appsvc_subnet.id
}

output "subnet_sql_id" {
  value = azurerm_subnet.sql_subnet.id
}

output "sql_private_dns_zone_id" {
  value = azurerm_private_dns_zone.sql_database_dns_zone.id
}

