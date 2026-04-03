resource "azurerm_private_dns_zone" "key_vault_dns_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.shared_resource_group
}

resource "azurerm_private_dns_zone" "databricks_dns_zone" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = var.shared_resource_group
}

resource "azurerm_private_dns_zone" "cosmosdb_dns_zone" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = var.shared_resource_group
}

resource "azurerm_private_dns_zone" "storage_account_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.shared_resource_group
}
resource "azurerm_private_dns_zone" "sql_database_dns_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.shared_resource_group
}
resource "azurerm_private_dns_zone" "web_app_dns_zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.shared_resource_group
}

resource "azurerm_private_dns_zone" "acr_dns_zone" {
  count = var.create_acr_private_dns_zone ? 1 : 0

  name                = "privatelink.azurecr.io"
  resource_group_name = var.shared_resource_group
}
