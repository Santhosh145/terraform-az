terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100" # You can change this version to the one you need
    }
  }

  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}
}
