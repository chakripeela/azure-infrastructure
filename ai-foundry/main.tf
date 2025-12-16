resource "azurerm_ai_foundry" "ai_foundry" {
  name                = "ai-foundry-${var.application_name}-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  storage_account_id  = var.storage_account_id
  key_vault_id        = var.key_vault_id
  identity {
    type = "SystemAssigned"
  }
}
