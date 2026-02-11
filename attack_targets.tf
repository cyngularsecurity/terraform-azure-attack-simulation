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