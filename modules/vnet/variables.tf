variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "address_space" {
  description = "Address space for the VNET (list of CIDR blocks)"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnets to create inside the VNET"
  type = map(object({
    address_prefix = string
  }))
  default = {
    default = {
      address_prefix = "10.0.1.0/24"
    }
  }
}

variable "enable_nsg" {
  description = "Whether to create and attach a Network Security Group to each subnet"
  type        = bool
  default     = true
}

variable "enable_ddos_protection" {
  description = "Whether to enable DDoS protection on the VNET (incurs cost)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}