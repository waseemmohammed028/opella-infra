# Azure VNET Module

Reusable Terraform module to deploy an Azure Virtual Network with optional subnets, NSGs, and DDoS protection.

## Usage

<!-- prettier-ignore -->
    module "vnet" {
      source              = "../../modules/vnet"
      vnet_name           = "opella-dev-eastus-vnet"
      location            = "eastus"
      resource_group_name = azurerm_resource_group.this.name
      address_space       = ["10.0.0.0/16"]

      subnets = {
        app = { address_prefix = "10.0.1.0/24" }
        db  = { address_prefix = "10.0.2.0/24" }
      }

      enable_nsg             = true
      enable_ddos_protection = false

      tags = {
        Environment = "dev"
        Project     = "opella"
        ManagedBy   = "Terraform"
      }
    }

## Inputs

| Name                   | Description                  | Type           | Default          | Required |
|------------------------|------------------------------|----------------|------------------|----------|
| vnet_name              | Name of the Virtual Network  | string         | -                | yes      |
| location               | Azure region                 | string         | -                | yes      |
| resource_group_name    | Resource Group name          | string         | -                | yes      |
| address_space          | CIDR blocks for VNET         | list(string)   | ["10.0.0.0/16"]  | no       |
| subnets                | Map of subnets               | map(object)    | see variables.tf | no       |
| enable_nsg             | Attach NSG to each subnet    | bool           | true             | no       |
| enable_ddos_protection | Enable DDoS plan             | bool           | false            | no       |
| tags                   | Resource tags                | map(string)    | {}               | no       |

## Outputs

| Name               | Description                  |
|--------------------|------------------------------|
| vnet_id            | The VNET resource ID         |
| vnet_name          | The VNET name                |
| vnet_address_space | The address space            |
| subnet_ids         | Map of subnet name to ID     |
| nsg_ids            | Map of NSG name to ID        |

## Notes

- NSGs are created per subnet with a deny-all inbound baseline rule
- DDoS protection is disabled by default (incurs cost if enabled)
- All resources inherit the tags passed to the module
- State is stored remotely in Azure Blob Storage