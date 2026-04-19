data "azurerm_client_config" "current" {}

locals {
  key_vault_regions = merge(
    {
      primary = {
        application_name               = var.application_name
        location                       = var.location
        resource_group_name            = module.resource_group.resource_group_name
        aks_secrets_provider_object_id = module.aks.key_vault_secrets_provider_object_id
        db_server                      = var.is_dr ? module.sql.sql_failover_group_fqdn : module.sql.sql_server_fqdn
        db_name                        = module.sql.sql_database_name
        managed_identity_client_id     = module.aks.kubelet_client_id
      }
    },
    var.is_dr ? {
      dr = {
        application_name               = var.application_name
        location                       = var.dr_location
        resource_group_name            = module.resource_group_dr[0].resource_group_name
        aks_secrets_provider_object_id = module.aks_dr[0].key_vault_secrets_provider_object_id
        db_server                      = module.sql.sql_failover_group_fqdn
        db_name                        = module.sql.sql_database_name
        managed_identity_client_id     = module.aks_dr[0].kubelet_client_id
      }
    } : {}
  )

  key_vault_names = {
    for region_key, config in local.key_vault_regions :
    region_key => substr(
      "kv${replace(lower(config.application_name), "/[^a-z0-9]/", "")}${replace(lower(config.location), "/[^a-z0-9]/", "")}",
      0,
      24
    )
  }
}

resource "azurerm_key_vault" "api_secrets" {
  for_each = local.key_vault_regions

  name                = local.key_vault_names[each.key]
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  lifecycle {
    ignore_changes = [soft_delete_retention_days]
  }
}

resource "azurerm_key_vault_access_policy" "current" {
  for_each = local.key_vault_regions

  key_vault_id = azurerm_key_vault.api_secrets[each.key].id
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
  for_each = local.key_vault_regions

  depends_on = [azurerm_key_vault_access_policy.current]

  create_duration = "30s"
}

resource "azurerm_key_vault_access_policy" "aks_secrets_provider" {
  for_each = local.key_vault_regions

  key_vault_id = azurerm_key_vault.api_secrets[each.key].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.aks_secrets_provider_object_id

  secret_permissions = [
    "Get",
    "List",
  ]
}

resource "azurerm_key_vault_secret" "db_server" {
  for_each = local.key_vault_regions

  name         = "db-server"
  value        = each.value.db_server
  key_vault_id = azurerm_key_vault.api_secrets[each.key].id

  depends_on = [time_sleep.wait_for_key_vault_policy]
}

resource "azurerm_key_vault_secret" "db_name" {
  for_each = local.key_vault_regions

  name         = "db-name"
  value        = each.value.db_name
  key_vault_id = azurerm_key_vault.api_secrets[each.key].id

  depends_on = [time_sleep.wait_for_key_vault_policy]
}

resource "azurerm_key_vault_secret" "managed_identity_client_id" {
  for_each = local.key_vault_regions

  name         = "managed-identity-client-id"
  value        = each.value.managed_identity_client_id
  key_vault_id = azurerm_key_vault.api_secrets[each.key].id

  depends_on = [time_sleep.wait_for_key_vault_policy]
}

resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  for_each = local.key_vault_regions

  name                       = "key-vault-diagnostic-${each.key}"
  target_resource_id         = azurerm_key_vault.api_secrets[each.key].id
  log_analytics_workspace_id = module.log_analytics.workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  enabled_log {
    category = "AllMetrics"
  }
}
