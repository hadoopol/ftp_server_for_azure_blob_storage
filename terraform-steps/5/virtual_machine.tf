resource "azurerm_virtual_network" "main" {
  name                = "ftp-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.RESOURCE_GROUP_REGION
  resource_group_name = var.RESOURCE_GROUP_NAME
}

resource "azurerm_subnet" "subnetinternal" {
  name                 = "ftp-subnet"
  resource_group_name  = var.RESOURCE_GROUP_NAME
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "ftp-pip"
  resource_group_name = var.RESOURCE_GROUP_NAME
  location            = var.RESOURCE_GROUP_REGION
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "ftp-nic1"
  resource_group_name = var.RESOURCE_GROUP_NAME
  location            = var.RESOURCE_GROUP_REGION

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.subnetinternal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_security_group" "sg" {
  name = "ftp_server"
  resource_group_name = var.RESOURCE_GROUP_NAME
  location = var.RESOURCE_GROUP_REGION
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.sg.id
}

resource "azurerm_network_security_rule" "ftpserver1" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "ftp1"
  priority                    = 101
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "990"
  destination_address_prefix  = "*"
  resource_group_name         = var.RESOURCE_GROUP_NAME
  network_security_group_name = azurerm_network_security_group.sg.name
}

resource "azurerm_network_security_rule" "ftpserver2" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "ftp2"
  priority                    = 102
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "40000-41000"
  destination_address_prefix  = "*"
  resource_group_name         = var.RESOURCE_GROUP_NAME
  network_security_group_name = azurerm_network_security_group.sg.name
}

resource "azurerm_network_security_rule" "ftpserver3" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "ftp3"
  priority                    = 103
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "20-21"
  destination_address_prefix  = "*"
  resource_group_name         = var.RESOURCE_GROUP_NAME
  network_security_group_name = azurerm_network_security_group.sg.name
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "ftp-vm"
  resource_group_name             = var.RESOURCE_GROUP_NAME
  location                        = var.RESOURCE_GROUP_REGION
  size                            = "Standard_B1ls"
  custom_data                     = filebase64("${path.module}/../../cloud_init.sh")
  disable_password_authentication = true
  admin_username = var.VM_ADMIN_USERNAME
  admin_ssh_key {
    public_key = file("${path.module}/../../id_rsa.pub")
    username = var.VM_ADMIN_USERNAME
  }
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}