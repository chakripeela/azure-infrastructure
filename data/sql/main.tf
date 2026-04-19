resource "azurerm_mssql_server" "sql_server" {
  name                          = var.sql_server_name
  resource_group_name           = var.resource_group_name
  location                      = var.sql_server_location
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  azuread_administrator {
    login_username              = var.sql_aad_admin_login
    object_id                   = var.sql_aad_admin_object_id
    azuread_authentication_only = true
  }
}

resource "azurerm_mssql_database" "sql_database" {
  count          = var.create_database ? 1 : 0
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.sql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "Basic"
  zone_redundant = false
}

resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "pep-${var.application_name}-sql"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.application_name}-sql"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-zone-group"
    private_dns_zone_ids = [var.sql_private_dns_zone_id]
  }
}

# DR/Geo-replication: Only create failover group in primary region
resource "azurerm_mssql_failover_group" "sql_failover_group" {
  count     = var.enable_failover_group && var.create_database ? 1 : 0
  name      = "failover-group-${var.application_name}"
  server_id = azurerm_mssql_server.sql_server.id
  databases = [azurerm_mssql_database.sql_database[0].id]
  partner_server {
    id = var.dr_sql_server_id
  }
  read_write_endpoint_failover_policy {
    mode = "Manual"
  }
}

resource "azurerm_monitor_diagnostic_setting" "sql_server" {
  name                       = "sql-server-diagnostic"
  target_resource_id         = azurerm_mssql_server.sql_server.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "SQLInsights"
  }

  enabled_log {
    category = "AutomaticTuning"
  }

  enabled_log {
    category = "QueryStoreRuntimeStatistics"
  }

  enabled_log {
    category = "QueryStoreWaitStatistics"
  }

  enabled_log {
    category = "Errors"
  }

  enabled_log {
    category = "DatabaseWaitStatistics"
  }

  enabled_log {
    category = "Timeouts"
  }

  enabled_log {
    category = "Blocks"
  }

  enabled_log {
    category = "Deadlocks"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
