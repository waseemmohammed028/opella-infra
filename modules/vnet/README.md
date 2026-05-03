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

## Security

- NSGs are created per subnet with two rules:
  - Allow RDP (port 3389) from within VirtualNetwork at priority 100
  - Deny all inbound traffic at priority 4096 (baseline)
- DDoS protection is disabled by default (incurs cost if enabled)
- All storage containers are private — no public blob access
- VM passwords are managed via GitHub Secrets — never hardcoded

## Notes

- All resources inherit the tags passed to the module
- State is stored remotely in Azure Blob Storage
- Naming convention: `{resource}-{project}-{environment}-{region}`

## Testing

This module uses [Terratest](https://terratest.gruntwork.io/) for automated testing.
Test documentation is available in the `tests/` directory.

| Test | Description |
|------|-------------|
| TestVnetCreated | Verifies VNET is created with correct address space |
| TestSubnetsCreated | Verifies subnets exist with correct CIDRs |
| TestNsgAttached | Verifies NSG is attached when enable_nsg = true |
| TestNsgSkipped | Verifies no NSG when enable_nsg = false |
| TestDdosDisabledByDefault | Verifies DDoS plan not created by default |

## Documentation

This README is automatically validated by terraform-docs in the CI/CD pipeline.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
