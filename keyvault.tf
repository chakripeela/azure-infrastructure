data "azurerm_client_config" "current" {}

locals {
  key_vault_application_name = replace(lower(var.application_name), "/[^a-z0-9]/", "")
  key_vault_location_name    = replace(lower(var.location), "/[^a-z0-9]/", "")
  key_vault_name             = substr("kv${local.key_vault_application_name}${local.key_vault_location_name}${substr(replace(lower(data.azurerm_client_config.current.subscription_id), "-", ""), 0, 6)}", 0, 24)
}

resource "azurerm_key_vault" "api_secrets" {
  name                = local.key_vault_name
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

resource "azurerm_key_vault_access_policy" "current" {
  key_vault_id = azurerm_key_vault.api_secrets.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Purge"
  ]
}

resource "time_sleep" "wait_for_key_vault_policy" {
  depends_on = [azurerm_key_vault_access_policy.current]

  create_duration = "30s"
}

resource "azurerm_key_vault_access_policy" "aks_secrets_provider" {
  key_vault_id = azurerm_key_vault.api_secrets.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.aks.key_vault_secrets_provider_object_id

  secret_permissions = [
    "Get",
    "List",
  ]
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

resource "azurerm_key_vault_secret" "managed_identity_client_id" {
  name         = "managed-identity-client-id"
  value        = module.aks.kubelet_client_id
  key_vault_id = azurerm_key_vault.api_secrets.id

  depends_on = [time_sleep.wait_for_key_vault_policy]
}
