output "resource_group_name" {
  description = "Name of the dev resource group"
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "ID of the dev VNET"
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "Name of the dev VNET"
  value       = module.vnet.vnet_name
}

output "subnet_ids" {
  description = "Subnet IDs in dev VNET"
  value       = module.vnet.subnet_ids
}

output "storage_account_name" {
  description = "Name of the dev storage account"
  value       = azurerm_storage_account.this.name
}

output "vm_name" {
  description = "Name of the dev Virtual Machine"
  value       = azurerm_windows_virtual_machine.this.name
}