
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
  value       = local.resource_group_name
}

output "vm_name" {
  description = "Name of the VM"
  value       = var.create_vm ? azurerm_linux_virtual_machine.attack_sim[0].name : null
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = var.create_vm ? azurerm_public_ip.attack_sim[0].ip_address : null
}

output "vm_admin_username" {
  description = "Admin username for SSH"
  value       = var.create_vm ? var.admin_username : null
}

output "vm_principal_id" {
  description = "Principal ID of the VM's managed identity"
  value       = local.vm_principal_id
}

output "ssh_connection_command" {
  description = "SSH connection command"
  value       = var.create_vm ? "ssh ${var.admin_username}@${azurerm_public_ip.attack_sim[0].ip_address}" : null
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
  sensitive   = true
  value       = <<-EOT
#=====Instructions=====

# Azure Attack Simulation Environment Variables
# This file contains the configuration needed for the attack simulations.

#Ensure you have an Azure VM with:
#    - A Managed Identity (System-assigned) with appropriate permissions
#    - SSH access enabled (port 22 open in NSG)


#=====SSH Connection Settings=====

# Public IP address of the target Azure VM
AZURE_VM_PUBLIC_IP=${var.create_vm ? azurerm_public_ip.attack_sim[0].ip_address : "N/A"}
# SSH username for the target VM
AZURE_VM_USERNAME=${var.create_vm ? var.admin_username : "N/A"}
# SSH password for the target VM
AZURE_VM_PASSWORD=${var.create_vm ? coalesce(var.admin_password, "N/A") : "N/A"}

#=====Azure Environment Settings=====

# Azure Subscription ID where the target resources are located
AZURE_SUBSCRIPTION_ID=${data.azurerm_subscription.current.subscription_id}
# Azure Resource Group name where the target VM is located
AZURE_RESOURCE_GROUP=${local.resource_group_name}
# Name of the target Azure VM
AZURE_VM_NAME=${var.create_vm ? azurerm_linux_virtual_machine.attack_sim[0].name : "N/A"}


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
    client         = var.client_name
    suffix         = local.name_suffix
    resource_group = local.resource_group_name
    location       = local.resource_group_location
    vm_name        = var.create_vm ? azurerm_linux_virtual_machine.attack_sim[0].name : "N/A (client-managed)"
    vm_ip          = var.create_vm ? azurerm_public_ip.attack_sim[0].ip_address : "N/A (client-managed)"
    auth_method    = "password"
    keyvault       = azurerm_key_vault.attack_sim.name
    storage        = azurerm_storage_account.attack_sim.name
    function_app   = azurerm_linux_function_app.attack_sim.name
  }
}
