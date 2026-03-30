variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  nullable    = false
}

variable "client_name" {
  description = "Client name for resource naming (max 8 chars, lowercase alphanumeric only for storage compatibility)"
  type        = string

  validation {
    condition     = length(var.client_name) <= 8 && length(var.client_name) >= 3
    error_message = "Client name must be between 3-8 characters"
  }

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.client_name))
    error_message = "Client name must be lowercase alphanumeric only (no hyphens, underscores, or special characters)"
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "function_app_sku" {
  description = "The SKU for the Function App Service Plan (e.g., B1, S1, P1v2). Must support Linux."
  type        = string
  default     = "B1"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM (must be 12+ chars with uppercase, lowercase, number, and special character)"
  type        = string
  sensitive   = true
  default     = null
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "allowed_ssh_source_ips" {
  description = "List of source IP addresses allowed to SSH (use [\"0.0.0.0/0\"] for any, but restrict in production)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Bring-your-own-VM configuration

variable "create_vm" {
  description = "Whether to create the VM and its network stack. Set to false for bring-your-own-VM."
  type        = bool
  default     = true
}

variable "existing_resource_group_name" {
  description = "Name of an existing resource group (required when create_vm = false)"
  type        = string
  default     = null

  validation {
    condition     = var.existing_resource_group_name != null || var.create_vm
    error_message = "existing_resource_group_name is required when create_vm = false."
  }
}

variable "existing_resource_group_location" {
  description = "Location of the existing resource group (required when create_vm = false)"
  type        = string
  default     = null

  validation {
    condition     = var.existing_resource_group_location != null || var.create_vm
    error_message = "existing_resource_group_location is required when create_vm = false."
  }
}

variable "existing_subnet_id" {
  description = "Subnet ID for Key Vault network ACL (required when create_vm = false)"
  type        = string
  default     = null

  validation {
    condition     = var.existing_subnet_id != null || var.create_vm
    error_message = "existing_subnet_id is required when create_vm = false."
  }
}

variable "assign_vm_roles" {
  description = "Whether to create role assignments for the VM identity. Set to false if roles already exist."
  type        = bool
  default     = true
}

variable "existing_vm_principal_id" {
  description = "Managed identity principal ID of the existing VM (required when create_vm = false)"
  type        = string
  default     = null

  validation {
    condition     = var.existing_vm_principal_id != null || var.create_vm
    error_message = "existing_vm_principal_id is required when create_vm = false."
  }
}