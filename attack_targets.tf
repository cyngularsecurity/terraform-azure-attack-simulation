resource "azuread_application" "target_sp" {
  display_name = "sp-attack-sim-target-${local.name_suffix}"
  owners = [
    data.azurerm_client_config.current.object_id,
    azurerm_linux_virtual_machine.attack_sim.identity[0].principal_id
  ]
}

resource "azuread_service_principal" "target_sp" {
  client_id = azuread_application.target_sp.client_id
  owners = [
    data.azurerm_client_config.current.object_id,
    azurerm_linux_virtual_machine.attack_sim.identity[0].principal_id
  ]
}

resource "azuread_application_owner" "vm_owns_target_app" {
  application_id  = azuread_application.target_sp.id
  owner_object_id = azurerm_linux_virtual_machine.attack_sim.identity[0].principal_id

  depends_on = [
    azurerm_linux_virtual_machine.attack_sim,
    azuread_application.target_sp
  ]
}
