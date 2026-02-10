
output "client_name" {
  description = "Client name used for resource naming"
  value       = module.azure_attack_sim.client_name
}

output "name_suffix" {
  description = "Random suffix used for resource naming"
  value       = module.azure_attack_sim.name_suffix
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.azure_attack_sim.resource_group_name
}

output "vm_name" {
  description = "Name of the VM"
  value       = module.azure_attack_sim.vm_name
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = module.azure_attack_sim.vm_public_ip
}

output "vm_admin_username" {
  description = "Admin username for SSH"
  value       = module.azure_attack_sim.vm_admin_username
}

output "vm_principal_id" {
  description = "Principal ID of the VM's managed identity"
  value       = module.azure_attack_sim.vm_principal_id
}

output "ssh_private_key_path" {
  description = "Path to the SSH private key"
  value       = module.azure_attack_sim.ssh_private_key_path
}

output "ssh_public_key_path" {
  description = "Path to the SSH public key"
  value       = module.azure_attack_sim.ssh_public_key_path
}

output "ssh_connection_command" {
  description = "SSH connection command"
  value       = module.azure_attack_sim.ssh_connection_command
}

output "subscription_id" {
  description = "Azure subscription ID"
  value       = module.azure_attack_sim.subscription_id
}

output "keyvault_name" {
  description = "Name of the Key Vault"
  value       = module.azure_attack_sim.keyvault_name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.azure_attack_sim.storage_account_name
}

output "function_storage_name" {
  description = "Name of the function storage account"
  value       = module.azure_attack_sim.function_storage_name
}

output "function_app_name" {
  description = "Name of the function app"
  value       = module.azure_attack_sim.function_app_name
}

output "function_app_url" {
  description = "Function App URL"
  value       = module.azure_attack_sim.function_app_url
}

output "function_trigger_url" {
  description = "HTTP Trigger URL"
  value       = module.azure_attack_sim.function_trigger_url
}

output "function_vfs_url" {
  description = "VFS API URL"
  value       = module.azure_attack_sim.function_vfs_url
}

output "target_service_principal_object_id" {
  description = "Object ID of target service principal"
  value       = module.azure_attack_sim.target_service_principal_object_id
}

output "env_file_content" {
  description = "Content for .env file"
  value       = module.azure_attack_sim.env_file_content
  sensitive   = true
}

output "deployment_summary" {
  description = "Deployment summary"
  value       = module.azure_attack_sim.deployment_summary
}
