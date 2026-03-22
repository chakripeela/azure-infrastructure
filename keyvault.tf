data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "api_secrets" {
  name                = "todo-api-secrets"
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  lifecycle {
    ignore_changes = [soft_delete_retention_days]
  }
}

resource "azurerm_role_assignment" "current_key_vault_secrets_officer" {
  scope                = azurerm_key_vault.api_secrets.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "time_sleep" "wait_for_key_vault_policy" {
  depends_on = [azurerm_role_assignment.current_key_vault_secrets_officer]

  create_duration = "60s"
}

resource "azurerm_key_vault_secret" "db_server" {
  name         = "db-server"
  value        = module.sql.sql_server_fqdn
  key_vault_id = azurerm_key_vault.api_secrets.id

  depends_on = [time_sleep.wait_for_key_vault_policy]
}

resource "azurerm_key_vault_secret" "db_name" {
  name         = "db-name"
  value        = module.sql.sql_database_name
  key_vault_id = azurerm_key_vault.api_secrets.id

  depends_on = [time_sleep.wait_for_key_vault_policy]
}
