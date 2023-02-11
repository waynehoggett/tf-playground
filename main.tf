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
  tags = {
    "Workload name"         = "linuxtestvm"
    "Business criticality"  = "Low"
    "Operations commitment" = "Baseline only"
    "Operations team"       = "Central IT"
    "Environment"           = "Dev"
  }
}
