terraform {
  required_version = ">= 1.9.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.54.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.2.0"
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

module "azure_attack_sim" {
  source  = "cyngularsecurity/attack-simulation/azure"
  subscription_id = var.subscription_id
  client_name     = var.client_name

  location               = var.location
  vm_size                = var.vm_size
  admin_username         = var.admin_username
  vnet_address_space     = var.vnet_address_space
  subnet_address_prefix  = var.subnet_address_prefix
  allowed_ssh_source_ips = var.allowed_ssh_source_ips
}
