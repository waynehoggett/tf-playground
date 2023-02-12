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

# Key Vault Secrets
data "azurerm_key_vault" "keyvault" {
  name                = "kv-vmsecrets001"
  resource_group_name = "rg-secrets"
}

data "azurerm_key_vault_secret" "vmPassword" {
  name         = "vmPassword"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

# UVM1
resource "azurerm_public_ip" "pip-dev-uvm1" {
  name                = "pip-dev-uvm1"
  resource_group_name = azurerm_resource_group.linuxtestvm.name
  location            = azurerm_resource_group.linuxtestvm.location
  allocation_method   = "Static"

  tags = var.tags
}

resource "azurerm_network_interface" "nic-dev-uvm1" {
  name                = "nic-uvm1"
  resource_group_name = azurerm_resource_group.linuxtestvm.name
  location            = azurerm_resource_group.linuxtestvm.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_virtual_network.linuxtestvm.subnet.*.id[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-dev-uvm1.id
  }
}

resource "azurerm_linux_virtual_machine" "uvm1" {
  name                            = "uvm1"
  resource_group_name             = azurerm_resource_group.linuxtestvm.name
  location                        = azurerm_resource_group.linuxtestvm.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = data.azurerm_key_vault_secret.vmPassword.value
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic-dev-uvm1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
