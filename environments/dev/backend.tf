terraform {
  backend "azurerm" {
    resource_group_name  = "rg-opella-tfstate"
    storage_account_name = "opellatfstate9211"
    container_name       = "dev"
    key                  = "dev.terraform.tfstate"
  }
}