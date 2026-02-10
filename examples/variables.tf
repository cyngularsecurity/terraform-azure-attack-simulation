variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  nullable    = false
}

variable "client_name" {
  description = "Client name for resource naming (3-8 chars, lowercase alphanumeric only)"
  type        = string

  validation {
    condition     = length(var.client_name) <= 8 && length(var.client_name) >= 3
    error_message = "Client name must be between 3-8 characters"
  }

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.client_name))
    error_message = "Client name must be lowercase alphanumeric only"
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

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
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
  description = "List of source IP addresses allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
