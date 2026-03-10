resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  numeric = false
  special = false
}

locals {
  name_suffix = random_string.suffix.result

  standard_name_pattern = "${var.client_name}-${local.name_suffix}"

  storage_name_pattern = "${var.client_name}${local.name_suffix}"

  resource_group_name     = var.create_vm ? azurerm_resource_group.attack_sim[0].name : var.existing_resource_group_name
  resource_group_location = var.create_vm ? azurerm_resource_group.attack_sim[0].location : var.existing_resource_group_location
  subnet_id               = var.create_vm ? azurerm_subnet.attack_sim[0].id : var.existing_subnet_id
  vm_principal_id         = var.create_vm ? azurerm_linux_virtual_machine.attack_sim[0].identity[0].principal_id : var.existing_vm_principal_id

  vm_name        = "vm-${local.standard_name_pattern}"
  vnet_name      = "vnet-${local.standard_name_pattern}"
  subnet_name    = "snet-${local.standard_name_pattern}"
  nsg_name       = "nsg-${local.standard_name_pattern}"
  nic_name       = "nic-${local.standard_name_pattern}"
  public_ip_name = "pip-${local.standard_name_pattern}"

  keyvault_name = "kv-${local.standard_name_pattern}"

  storage_account_name  = "st${local.storage_name_pattern}"
  function_storage_name = "stfunc${local.storage_name_pattern}"

  function_app_name     = "func-${local.standard_name_pattern}"
  app_service_plan_name = "asp-${local.standard_name_pattern}"


  common_tags = {
    Environment = "Attack Simulation"
    ManagedBy   = "Terraform"
    Client      = var.client_name
    Purpose     = "Security Testing"
  }
}
