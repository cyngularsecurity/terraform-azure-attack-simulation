variable "subscription_id" {
  description = "Client subscription ID"
  type        = string
  nullable    = false
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-pentest3546"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "pentest-vm26"
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
  default     = ["0.0.0.0/0"] # CHANGE THIS TO YOUR IP!
}

variable "keyvault_name" {
  description = "Name of the Key Vault (must be globally unique)"
  type        = string
  default     = "kv-pentest-test-789"
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
  default     = "storagepentest789"
}

variable "function_storage_name" {
  description = "Name of the function storage account (must be globally unique)"
  type        = string
  default     = "funcstoragepentest789"
}

variable "function_app_name" {
  description = "Name of the Function App (must be globally unique)"
  type        = string
  default     = "func-pentest-test-789"
}
