terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

module "azure_pentest" {
  source = "./modules/azure_pentest"

  resource_group_name = var.resource_group_name
  location            = var.location
  vm_name             = var.vm_name
  vm_size             = var.vm_size
  admin_username      = var.admin_username

  vnet_address_space     = var.vnet_address_space
  subnet_address_prefix  = var.subnet_address_prefix
  allowed_ssh_source_ips = var.allowed_ssh_source_ips

  keyvault_name         = var.keyvault_name
  storage_account_name  = var.storage_account_name
  function_storage_name = var.function_storage_name
  function_app_name     = var.function_app_name
}
