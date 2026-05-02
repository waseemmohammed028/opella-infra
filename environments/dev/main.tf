terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  prefix = "${var.project}-${var.environment}-${var.location}"
  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Owner       = "DevOps"
  }
}

# Resource Group
resource "azurerm_resource_group" "this" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}

# VNET module
module "vnet" {
  source              = "../../modules/vnet"
  vnet_name           = "vnet-${local.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]

  subnets = {
    app = { address_prefix = "10.0.1.0/24" }
    db  = { address_prefix = "10.0.2.0/24" }
  }

  enable_nsg             = true
  enable_ddos_protection = false
  tags                   = local.tags
}

# Storage Account (Blob)
resource "azurerm_storage_account" "this" {
  name                     = "st${var.project}${var.environment}${substr(var.location, 0, 4)}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.tags
}

resource "azurerm_storage_container" "this" {
  name                  = "app-data"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# Virtual Machine - NIC
resource "azurerm_network_interface" "this" {
  name                = "nic-${local.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.subnet_ids["app"]
    private_ip_address_allocation = "Dynamic"
  }
}

# Virtual Machine
resource "azurerm_windows_virtual_machine" "this" {
  name                = "vm-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  tags                = local.tags

  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}