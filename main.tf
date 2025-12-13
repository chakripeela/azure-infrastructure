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
  source              = "./virtual-network"
  application_name    = var.application_name
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name
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
  source                                = "./databricks"
  application_name                      = var.application_name
  location                              = var.location
  resource_group_name                   = module.resource_group.resource_group_name
  managed_services_cmk_key_vault_key_id = module.key_vault.managed_services_cmk_key_vault_key_id
  managed_disk_cmk_key_vault_key_id     = module.key_vault.managed_disk_cmk_key_vault_key_id

}
