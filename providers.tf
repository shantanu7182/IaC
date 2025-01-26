terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.18.1"
    }
  }
}

provider "azurerm" {
  features {}
}
