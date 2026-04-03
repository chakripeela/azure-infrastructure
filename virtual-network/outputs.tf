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

output "subnet_aks_id" {
  value = azurerm_subnet.aks_subnet.id
}

output "subnet_acr_private_endpoint_id" {
  value = azurerm_subnet.acr_private_endpoint_subnet.id
}

output "sql_private_dns_zone_id" {
  value = azurerm_private_dns_zone.sql_database_dns_zone.id
}

output "acr_private_dns_zone_id" {
  value = var.create_acr_private_dns_zone ? azurerm_private_dns_zone.acr_dns_zone[0].id : null
}

output "subnet_appgw_id" {
  value = azurerm_subnet.appgw_subnet.id
}

output "subnet_appgw_name" {
  value = azurerm_subnet.appgw_subnet.name
}

output "vnet_frontend_name" {
  value = azurerm_virtual_network.vnet_frontend.name
}

output "vnet_appgw_id" {
  value = azurerm_virtual_network.vnet_appgw.id
}

output "appgw_nsg_id" {
  value = azurerm_network_security_group.appgw_nsg.id
}

output "appgw_nsg_assoc_id" {
  value = azurerm_subnet_network_security_group_association.appgw_nsg_assoc.id  
}
