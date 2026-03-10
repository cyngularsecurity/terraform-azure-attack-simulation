# Virtual Network
resource "azurerm_virtual_network" "attack_sim" {
  count               = var.create_vm ? 1 : 0
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.attack_sim[0].name
  location            = azurerm_resource_group.attack_sim[0].location
  address_space       = var.vnet_address_space

  tags = local.common_tags
}

resource "azurerm_subnet" "attack_sim" {
  count                = var.create_vm ? 1 : 0
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.attack_sim[0].name
  virtual_network_name = azurerm_virtual_network.attack_sim[0].name
  address_prefixes     = var.subnet_address_prefix
  service_endpoints    = ["Microsoft.KeyVault"]
}

resource "azurerm_network_security_group" "attack_sim" {
  count               = var.create_vm ? 1 : 0
  name                = local.nsg_name
  resource_group_name = azurerm_resource_group.attack_sim[0].name
  location            = azurerm_resource_group.attack_sim[0].location

  tags = local.common_tags
}

resource "azurerm_network_security_rule" "allow_ssh" {
  count                       = var.create_vm ? 1 : 0
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.allowed_ssh_source_ips
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.attack_sim[0].name
  network_security_group_name = azurerm_network_security_group.attack_sim[0].name
}

resource "azurerm_public_ip" "attack_sim" {
  count               = var.create_vm ? 1 : 0
  name                = local.public_ip_name
  resource_group_name = azurerm_resource_group.attack_sim[0].name
  location            = azurerm_resource_group.attack_sim[0].location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

resource "azurerm_network_interface" "attack_sim" {
  count               = var.create_vm ? 1 : 0
  name                = local.nic_name
  resource_group_name = azurerm_resource_group.attack_sim[0].name
  location            = azurerm_resource_group.attack_sim[0].location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.attack_sim[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.attack_sim[0].id
  }

  tags = local.common_tags
}

resource "azurerm_network_interface_security_group_association" "attack_sim" {
  count                     = var.create_vm ? 1 : 0
  network_interface_id      = azurerm_network_interface.attack_sim[0].id
  network_security_group_id = azurerm_network_security_group.attack_sim[0].id
}
