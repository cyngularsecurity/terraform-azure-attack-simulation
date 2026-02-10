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

  resource_group_name = "rg-${local.standard_name_pattern}"
  vm_name             = "vm-${local.standard_name_pattern}"
  vnet_name           = "vnet-${local.standard_name_pattern}"
  subnet_name         = "snet-${local.standard_name_pattern}"
  nsg_name            = "nsg-${local.standard_name_pattern}"
  nic_name            = "nic-${local.standard_name_pattern}"
  public_ip_name      = "pip-${local.standard_name_pattern}"

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
