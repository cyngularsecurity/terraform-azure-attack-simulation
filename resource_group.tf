resource "azurerm_resource_group" "attack_sim" {
  count    = var.create_vm ? 1 : 0
  name     = "rg-${local.standard_name_pattern}"
  location = var.location

  tags = local.common_tags
}
