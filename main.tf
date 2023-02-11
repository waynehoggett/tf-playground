terraform {
  cloud {
    organization = "WayneHoggett"
    workspaces {
      name = "tf-playground"
    }
  }
  required_providers {
    azurerm = {
      "source" = "hashicorp/azurerm"
      version  = "3.43.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "linuxtestvm" {
  name     = "rg-linuxtestvm-dev-001"
  location = "Australia East"
  tags     = var.tags
}

resource "azurerm_virtual_network" "linuxtestvm" {
  name                = "vnet-dev-australiaeast-001"
  resource_group_name = azurerm_resource_group.linuxtestvm.name
  location            = azurerm_resource_group.linuxtestvm.location
  address_space       = ["10.0.0.0/16"]
  subnet = [{
    name           = "snet-servers"
    address_prefix = "10.0.0.0/24"
  }]
  tags = var.tags
}
