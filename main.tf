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
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.6.1"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
resource "local_file" "dotenv" {
  filename        = "${path.root}/.env"
  file_permission = "0600"
  content         = <<-EOF

#=====SSH Connection Settings=====

# Path to the SSH private key for the target VM
# Public IP address of the target Azure VM
AZURE_VM_PUBLIC_IP=${var.create_vm ? azurerm_public_ip.attack_sim[0].ip_address : "N/A"}
AZURE_VM_USERNAME=${var.create_vm ? var.admin_username : "N/A"}
AZURE_VM_PASS=${var.create_vm ? var.admin_password : "N/A"}

#=====Azure Environment Settings=====

# Azure Subscription ID where the target resources are located
AZURE_SUBSCRIPTION_ID=${data.azurerm_subscription.current.subscription_id}
# Azure Resource Group name where the target VM is located
AZURE_RESOURCE_GROUP=${local.resource_group_name}
# Name of the target Azure VM
AZURE_VM_NAME=${var.create_vm ? azurerm_linux_virtual_machine.attack_sim[0].name : "N/A"}


#=====Penetration Tests Resources=====

#keyvault_config_attack
KEYVAULT_NAME=${azurerm_key_vault.attack_sim.name}
#storage_keys_attack
STORAGE_ACCOUNT_NAME=${azurerm_storage_account.attack_sim.name}
#function_app_config_attack
FUNCTION_APP_NAME=${azurerm_linux_function_app.attack_sim.name}
#role_assignment_attack
TARGET_PRINCIPAL_ID=${azuread_service_principal.target_sp.object_id}
EOF
}
