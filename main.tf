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
