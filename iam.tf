resource "azurerm_role_assignment" "vm_reader" {
  count                = var.assign_vm_roles ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = local.vm_principal_id
}

resource "azurerm_role_assignment" "vm_contributor_rg" {
  count                = var.assign_vm_roles ? 1 : 0
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${local.resource_group_name}"
  role_definition_name = "Contributor"
  principal_id         = local.vm_principal_id
}

resource "azurerm_role_assignment" "vm_user_access_admin" {
  count                = var.assign_vm_roles ? 1 : 0
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${local.resource_group_name}"
  role_definition_name = "User Access Administrator"
  principal_id         = local.vm_principal_id
}

resource "azuread_app_role_assignment" "vm_graph_app_readwrite_owned" {
  count               = var.assign_vm_roles ? 1 : 0
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.OwnedBy"]
  principal_object_id = local.vm_principal_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}
