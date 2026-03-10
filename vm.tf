resource "azurerm_linux_virtual_machine" "attack_sim" {
  count               = var.create_vm ? 1 : 0
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.attack_sim[0].name
  location            = azurerm_resource_group.attack_sim[0].location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.attack_sim[0].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.attack_sim_ssh[0].public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

}
