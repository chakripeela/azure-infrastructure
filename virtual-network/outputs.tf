output "vnet_frontend_id" {
  value = azurerm_virtual_network.vnet_frontend.id
}

output "subnet_appsvc_id" {
  value = azurerm_subnet.appsvc_subnet.id
}

