terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.55.0"
    }
  }
}


provider "azurerm" {
  # Configuration options
  features {}
}


module "resource-group" {
  source = "./resource-group"

}

