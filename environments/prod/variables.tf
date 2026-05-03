variable "location" {
  description = "Azure region for prod environment"
  type        = string
  default     = "westeurope"
}

variable "project" {
  description = "Project name used in resource naming"
  type        = string
  default     = "opella"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "admin_username" {
  description = "Admin username for the Virtual Machine"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Admin password for the Virtual Machine"
  type        = string
  sensitive   = true
}