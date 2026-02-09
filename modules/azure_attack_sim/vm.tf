resource "azurerm_linux_virtual_machine" "attack_sim" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.attack_sim.name
  location            = azurerm_resource_group.attack_sim.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.attack_sim.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.attack_sim_ssh.public_key_openssh
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
