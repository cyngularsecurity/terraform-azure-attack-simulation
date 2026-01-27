output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.azure_pentest.resource_group_name
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = module.azure_pentest.vm_name
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = module.azure_pentest.vm_public_ip
}

output "vm_principal_id" {
  description = "Principal ID of the VM's managed identity"
  value       = module.azure_pentest.vm_principal_id
}

output "ssh_connection_command" {
  description = "SSH command to connect to the VM"
  value       = module.azure_pentest.ssh_connection_command
}

output "keyvault_name" {
  description = "Name of the Key Vault"
  value       = module.azure_pentest.keyvault_name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.azure_pentest.storage_account_name
}

output "function_app_name" {
  description = "Name of the Function App"
  value       = module.azure_pentest.function_app_name
}

output "subscription_id" {
  description = "Current subscription ID"
  value       = module.azure_pentest.subscription_id
}

output "env_file_content" {
  description = "Generated .env file content"
  value       = module.azure_pentest.env_file_content
  sensitive   = true
}
