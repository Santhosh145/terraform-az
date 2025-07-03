terraform {
  backend "azurerm" {
    resource_group_name   = "Demo-RG"
    storage_account_name  = "backendsgtfstaefile"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}
