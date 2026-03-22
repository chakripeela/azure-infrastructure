terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.55.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
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

module "app_service" {
  source                = "./compute/app-service"
  plan_name             = "${var.application_name}-plan"
  location              = var.location
  resource_group_name   = module.resource_group.resource_group_name
  subnet_id             = module.virtual_network.subnet_appsvc_id
  #shared_resource_group = module.resource_group.shared_resource_group_name
}

module "acr" {
  source                = "./compute/acr"
  acr_name              = "chakripeelaacr"
  location              = var.location
  resource_group_name   = module.resource_group.resource_group_name
}

module "aks" {
  source                = "./compute/aks"
  location              = var.location
  resource_group_name   = module.resource_group.resource_group_name
  subnet_id             = module.virtual_network.subnet_aks_id
}

module "sql" {
  source                  = "./data/sql"
  application_name        = var.application_name
  location                = var.location
  resource_group_name     = module.resource_group.resource_group_name
  subnet_id               = module.virtual_network.subnet_sql_id
  sql_private_dns_zone_id = module.virtual_network.sql_private_dns_zone_id
  sql_server_name         = var.sql_server_name
  sql_database_name       = var.sql_database_name
  sql_aad_admin_login     = var.sql_aad_admin_login
  sql_aad_admin_object_id = var.sql_aad_admin_object_id
}
