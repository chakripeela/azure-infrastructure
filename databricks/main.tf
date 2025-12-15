resource "azurerm_databricks_workspace" "databricks_workspace" {
  name                        = "${var.application_name}-${var.location}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  sku                         = "premium"
  managed_resource_group_name = "${var.resource_group_name}-mrg"
  # public_network_access_enabled = false
  customer_managed_key_enabled = true
  custom_parameters {
    virtual_network_id                                   = var.vnet_id
    private_subnet_name                                  = var.private_subnet_name
    public_subnet_name                                   = var.public_subnet_name
    public_subnet_network_security_group_association_id  = var.public_subnet_network_security_group_association_id
    private_subnet_network_security_group_association_id = var.private_subnet_network_security_group_association_id
  }
  managed_services_cmk_key_vault_key_id = var.managed_services_cmk_key_vault_key_id
  managed_disk_cmk_key_vault_key_id     = var.managed_disk_cmk_key_vault_key_id
}

