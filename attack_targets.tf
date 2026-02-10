resource "azuread_application" "target_sp" {
  display_name = "sp-attack-sim-target-${local.name_suffix}"
}

resource "azuread_service_principal" "target_sp" {
  client_id = azuread_application.target_sp.client_id
}
