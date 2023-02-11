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
  subnet {
    name           = "snet-servers"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.ssh.id
  }

  tags = var.tags

}

resource "azurerm_network_security_group" "ssh" {
  name                = "nsg-sshallow-001"
  resource_group_name = azurerm_resource_group.linuxtestvm.name
  location            = azurerm_resource_group.linuxtestvm.location

  security_rule {
    name                       = "allow-inbound-ssh"
    priority                   = 100
    description                = "Allow inbound SSH"
    access                     = "Allow"
    direction                  = "Inbound"
    destination_address_prefix = "VirtualNetwork"
    destination_port_range     = "22"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  tags = var.tags

}
