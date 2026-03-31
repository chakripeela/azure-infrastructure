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
  application_name      = var.application_name
  acr_name              = "chakripeelaacr"
  location              = var.location
  resource_group_name   = module.resource_group.resource_group_name
  subnet_id             = module.virtual_network.subnet_acr_private_endpoint_id
  acr_private_dns_zone_id = module.virtual_network.acr_private_dns_zone_id
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
  sql_aad_admin_login     = var.sql_aad_admin_login
  sql_aad_admin_object_id = var.sql_aad_admin_object_id
  sql_database_name = var.sql_database_name
  enable_failover_group   =  var.is_dr == "Yes" ? true : false
  dr_sql_server_id        = module.sql_dr[0].sql_server_id
}

# Conditional deployment: Application Gateway or Azure Front Door
module "app_gateway" {
  source              = "./compute/app-gateway"
  application_name    = var.application_name
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name
  subnet_id           = module.virtual_network.subnet_appgw_id
  app_service_fqdn    = module.app_service.app_service_default_hostname
  backend_ip          = "10.1.2.250"
  appgw_nsg_assoc_id = module.virtual_network.appgw_nsg_assoc_id
}

module "frontdoor" {
  source              = "./compute/frontdoor"
  application_name    = var.application_name
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name
  app_service_fqdn    = module.app_service.app_service_default_hostname
  dr_appgw_public_ip =  module.app_gateway_dr[0].appgw_public_ip
  dr_enabled         = true
  depends_on = [module.app_gateway, module.app_gateway_dr]
}

# DR Modules
# DR region resource group
module "resource_group_dr" {
  count = var.is_dr ? 1 : 0
  source           = "./resource-group"
  application_name = "${var.application_name}-dr"
  location         = var.dr_location
}
# DR region App Gateway
module "app_gateway_dr" {
  count = var.is_dr ? 1 : 0
  source              = "./compute/app-gateway"
  application_name    = "${var.application_name}-dr"
  location            = var.dr_location
  resource_group_name = module.resource_group_dr[0].resource_group_name
  subnet_id           = module.virtual_network_dr[0].subnet_appgw_id
  app_service_fqdn    = module.app_service_dr[0].app_service_default_hostname
  backend_ip          = "10.1.2.250"
  appgw_nsg_assoc_id = module.virtual_network_dr[0].appgw_nsg_assoc_id
}

# DR region SQL
module "sql_dr" {
  count = var.is_dr ? 1 : 0
  source                  = "./data/sql"
  application_name        = "${var.application_name}-dr"
  location                = var.dr_location
  resource_group_name     = module.resource_group_dr[0].resource_group_name
  subnet_id               = module.virtual_network_dr[0].subnet_sql_id
  sql_private_dns_zone_id = module.virtual_network_dr[0].sql_private_dns_zone_id
  sql_server_name         = "${var.sql_server_name}-dr"
  sql_database_name       = "${var.sql_database_name}-dr"
  sql_aad_admin_login     = var.sql_aad_admin_login
  sql_aad_admin_object_id = var.sql_aad_admin_object_id
}

# DR region AKS
module "aks_dr" {
  count = var.is_dr ? 1 : 0
  source                = "./compute/aks"
  location              = var.dr_location
  resource_group_name   = module.resource_group_dr[0].resource_group_name
  subnet_id             = module.virtual_network_dr[0].subnet_aks_id
}

# DR region ACR
module "acr_dr" {
  count = var.is_dr ? 1 : 0
  source                = "./compute/acr"
  application_name      = "${var.application_name}-dr"
  acr_name              = "chakripeelaacrdr"
  location              = var.dr_location
  resource_group_name   = module.resource_group_dr[0].resource_group_name
  subnet_id             = module.virtual_network_dr[0].subnet_acr_private_endpoint_id
  acr_private_dns_zone_id = module.virtual_network_dr[0].acr_private_dns_zone_id
}

# DR region app service
module "app_service_dr" {
  count = var.is_dr ? 1 : 0
  source                = "./compute/app-service"
  plan_name             = "${var.application_name}-dr-plan"
  location              = var.dr_location
  resource_group_name   = module.resource_group_dr[0].resource_group_name
  subnet_id             = module.virtual_network_dr[0].subnet_appsvc_id
  enabled               = false
}

# DR region virtual network
module "virtual_network_dr" {
  count = var.is_dr ? 1 : 0
  source                = "./virtual-network"
  application_name      = "${var.application_name}-dr"
  location              = var.dr_location
  resource_group_name   = module.resource_group_dr[0].resource_group_name
  shared_resource_group = module.resource_group_dr[0].shared_resource_group_name
}