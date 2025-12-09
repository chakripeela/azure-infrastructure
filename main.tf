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


module "resource-group" {
  source  = "./resource-group"
  rg-name = "data-maester-rg"
}

