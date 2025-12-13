resource "azurerm_role_assignment" "sp_role" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
resource "azurerm_role_assignment" "sp_role_officer" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "user_role" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Reader"
  principal_id         = "5aa1aa7a-08a6-4e98-b77d-295f6900fd8f"
}

resource "azurerm_role_assignment" "user_role_officer" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = "5aa1aa7a-08a6-4e98-b77d-295f6900fd8f"
}

resource "azurerm_role_assignment" "databricks_role" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Reader"
  principal_id         = "a7f76047-d094-45fa-a507-ec0e3d7bcfda"
}

resource "azurerm_role_assignment" "databricks_role_officer" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = "a7f76047-d094-45fa-a507-ec0e3d7bcfda"
}
