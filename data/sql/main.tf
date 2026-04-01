resource "azurerm_mssql_server" "sql_server" {
  name                          = var.sql_server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true

  azuread_administrator {
    login_username              = var.sql_aad_admin_login
    object_id                   = var.sql_aad_admin_object_id
    azuread_authentication_only = true
  }
}

resource "azurerm_mssql_database" "sql_database" {
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

resource "azurerm_mssql_firewall_rule" "allow_dacpac_ip" {
  name                = "AllowDacpacDeployment"
  server_id           = azurerm_mssql_server.sql_server.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

# DR/Geo-replication: Only create failover group in primary region
resource "azurerm_mssql_failover_group" "sql_failover_group" {
  count                 = var.enable_failover_group ? 1 : 0
  name                  = "failover-group-${var.application_name}"
  server_id             = azurerm_mssql_server.sql_server.id
  databases             = [azurerm_mssql_database.sql_database.id]
  partner_server {
    id = var.dr_sql_server_id
  }
  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
}
