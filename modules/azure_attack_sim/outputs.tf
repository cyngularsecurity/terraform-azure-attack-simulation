
output "client_name" {
  description = "Client name used for resource naming"
  value       = var.client_name
}

output "name_suffix" {
  description = "Random suffix used for resource naming"
  value       = local.name_suffix
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.attack_sim.name
}

output "vm_name" {
  description = "Name of the VM"
  value       = azurerm_linux_virtual_machine.attack_sim.name
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.attack_sim.ip_address
}

output "vm_admin_username" {
  description = "Admin username for SSH"
  value       = var.admin_username
}

output "vm_principal_id" {
  description = "Principal ID of the VM's managed identity"
  value       = azurerm_linux_virtual_machine.attack_sim.identity[0].principal_id
}

output "ssh_private_key_path" {
  description = "Path to the SSH private key on your local machine"
  value       = abspath(local_file.private_key.filename)
}

output "ssh_public_key_path" {
  description = "Path to the SSH public key on your local machine"
  value       = abspath(local_file.public_key.filename)
}

output "ssh_connection_command" {
  description = "SSH connection command"
  value       = "ssh -i ${abspath(local_file.private_key.filename)} ${var.admin_username}@${azurerm_public_ip.attack_sim.ip_address}"
}

output "subscription_id" {
  description = "Azure subscription ID"
  value       = data.azurerm_subscription.current.subscription_id
}

output "keyvault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.attack_sim.name
}

output "storage_account_name" {
  description = "Name of the storage account (attack target)"
  value       = azurerm_storage_account.attack_sim.name
}

output "function_storage_name" {
  description = "Name of the function app storage account"
  value       = azurerm_storage_account.function.name
}

output "function_app_name" {
  description = "Name of the function app"
  value       = azurerm_linux_function_app.attack_sim.name
}

output "function_app_url" {
  description = "Function App default URL"
  value       = "https://${azurerm_linux_function_app.attack_sim.default_hostname}"
}

output "function_trigger_url" {
  description = "HTTP Trigger function URL"
  value       = "https://${azurerm_linux_function_app.attack_sim.default_hostname}/api/http_trigger"
}

output "function_vfs_url" {
  description = "VFS API URL for file access"
  value       = "https://${azurerm_linux_function_app.attack_sim.name}.scm.azurewebsites.net/api/vfs/site/wwwroot/"
}

output "target_service_principal_object_id" {
  description = "Object ID of the target service principal for role assignment attacks"
  value       = azuread_service_principal.target_sp.object_id
}

output "env_file_content" {
  description = "Content for .env file"
  value       = <<-EOT
#=====Instructions=====

# Azure Attack Simulation Environment Variables
# This file contains the configuration needed for the attack simulations.

#Ensure you have an Azure VM with:
#    - A Managed Identity (System-assigned) with appropriate permissions
#    - SSH access enabled (port 22 open in NSG)
#    - The SSH private key saved as azure_attack.pem in this directory


#=====SSH Connection Settings=====

# Path to the SSH private key for the target VM
SSH_KEY_PATH=${abspath(local_file.private_key.filename)}
# Public IP address of the target Azure VM
AZURE_VM_PUBLIC_IP=${azurerm_public_ip.attack_sim.ip_address}
# SSH username for the target VM
AZURE_VM_USERNAME=${var.admin_username}

#=====Azure Environment Settings=====

# Azure Subscription ID where the target resources are located
AZURE_SUBSCRIPTION_ID=${data.azurerm_subscription.current.subscription_id}
# Azure Resource Group name where the target VM is located
AZURE_RESOURCE_GROUP=${azurerm_resource_group.attack_sim.name}
# Name of the target Azure VM
AZURE_VM_NAME=${azurerm_linux_virtual_machine.attack_sim.name}


#=====Attack Simulation Target Resources=====

#keyvault_config_attack
KEYVAULT_NAME=${azurerm_key_vault.attack_sim.name}
#storage_keys_attack
STORAGE_ACCOUNT_NAME=${azurerm_storage_account.attack_sim.name}
#function_app_config_attack
FUNCTION_APP_NAME=${azurerm_linux_function_app.attack_sim.name}
#role_assignment_attack
TARGET_PRINCIPAL_ID=${azuread_service_principal.target_sp.object_id}
EOT
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    client            = var.client_name
    suffix            = local.name_suffix
    resource_group    = azurerm_resource_group.attack_sim.name
    location          = azurerm_resource_group.attack_sim.location
    vm_name           = azurerm_linux_virtual_machine.attack_sim.name
    vm_ip             = azurerm_public_ip.attack_sim.ip_address
    ssh_key_location  = abspath(local_file.private_key.filename)
    keyvault          = azurerm_key_vault.attack_sim.name
    storage           = azurerm_storage_account.attack_sim.name
    function_app      = azurerm_linux_function_app.attack_sim.name
  }
}
