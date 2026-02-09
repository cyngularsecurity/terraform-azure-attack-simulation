resource "azurerm_role_assignment" "vm_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_virtual_machine.attack_sim.identity[0].principal_id
}

resource "azurerm_role_assignment" "vm_contributor_rg" {
  scope                = azurerm_resource_group.attack_sim.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_virtual_machine.attack_sim.identity[0].principal_id
}

resource "azurerm_role_assignment" "vm_user_access_admin" {
  scope                = azurerm_resource_group.attack_sim.id
  role_definition_name = "User Access Administrator"
  principal_id         = azurerm_linux_virtual_machine.attack_sim.identity[0].principal_id
}


resource "azuread_app_role_assignment" "vm_graph_app_readwrite" {
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
  principal_object_id = azurerm_linux_virtual_machine.attack_sim.identity[0].principal_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id

  depends_on = [
    azurerm_linux_virtual_machine.attack_sim
  ]
}