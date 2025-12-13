resource "azurerm_databricks_workspace" "databricks_workspace" {
  name                        = "${var.application_name}-dbw-${var.location}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  sku                         = "premium"
  managed_resource_group_name = "${var.resource_group_name}-mrg"

  managed_services_cmk_key_vault_key_id = var.managed_services_cmk_key_vault_key_id
  managed_disk_cmk_key_vault_key_id     = var.managed_disk_cmk_key_vault_key_id
}
