output "managed_disk_cmk_key_vault_key_id" {
  value = azurerm_key_vault_key.managed_disk_cmk_key.id
}

output "managed_services_cmk_key_vault_key_id" {
  value = azurerm_key_vault_key.managed_services_cmk_key.id
}
output "key_vault_id" {
  value = azurerm_key_vault.key_vault.id
}
