terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.55.0"
    }
  }
}


provider "azurerm" {
  features {}
}


module "resource_group" {
  source           = "./resource-group"
  application_name = var.application_name
  location         = var.location
}

module "virtual_network" {
  source                = "./virtual-network"
  application_name      = var.application_name
  location              = var.location
  resource_group_name   = module.resource_group.resource_group_name
  shared_resource_group = module.resource_group.shared_resource_group_name
}
module "storage_account" {
  source              = "./storage-account"
  application_name    = var.application_name
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name
}

module "key_vault" {
  source              = "./key-vault"
  application_name    = var.application_name
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name
}


module "databricks" {
  source                                               = "./databricks"
  application_name                                     = var.application_name
  location                                             = var.location
  resource_group_name                                  = module.resource_group.resource_group_name
  managed_services_cmk_key_vault_key_id                = module.key_vault.managed_services_cmk_key_vault_key_id
  managed_disk_cmk_key_vault_key_id                    = module.key_vault.managed_disk_cmk_key_vault_key_id
  vnet_id                                              = module.virtual_network.vnet_id
  private_subnet_name                                  = module.virtual_network.private_subnet_name
  public_subnet_name                                   = module.virtual_network.public_subnet_name
  public_subnet_network_security_group_association_id  = module.virtual_network.public_subnet_network_security_group_association_id
  private_subnet_network_security_group_association_id = module.virtual_network.private_subnet_network_security_group_association_id
  depends_on                                           = [module.virtual_network, module.key_vault]
}

module "open-ai-foundry" {
  source              = "./ai-foundry"
  application_name    = var.application_name
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name
  storage_account_id  = module.storage_account.storage_account_id
  key_vault_id        = module.key_vault.key_vault_id
  depends_on          = [module.storage_account, module.key_vault]
}
