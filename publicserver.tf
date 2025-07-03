resource "azurerm_public_ip" "PublicIP" {
  name                = "WebserverPublicIP1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_managed_disk" "public_data_disk" {
  name                 = "Publicserver-datadisk-vm"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 30
}

resource "azurerm_network_interface" "PublicNIC" {
  name                = "PublicNIC1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Public[0].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "PublicVM" {
  name                = "PublicVM1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "P@ssw0rd1234!"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.PublicNIC.id,
  ]

  os_disk {
    name                 = "publicserver-osdisk-vm"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "public_data_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.public_data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.PublicVM.id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_network_security_group" "public_nsg" {
  name                = "PublicNSG"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "public_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.PublicNIC.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}

resource "azurerm_lb" "public_lb" {
  name                = "PublicAppLB"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name = "PublicLBFrontEnd"
    public_ip_address_id = azurerm_public_ip.PublicIP.id // Commented out to allow public IP deletion
  }
}

resource "azurerm_lb_backend_address_pool" "public_lb_backend" {
  name            = "PublicLBBackendPool"
  loadbalancer_id = azurerm_lb.public_lb.id
}

resource "azurerm_lb_probe" "public_lb_probe" {
  name            = "PublicLBProbe"
  loadbalancer_id = azurerm_lb.public_lb.id
  protocol        = "Tcp"
  port            = 80
}

resource "azurerm_lb_rule" "public_lb_rule" {
  name                           = "PublicLBRule"
  loadbalancer_id                = azurerm_lb.public_lb.id
  protocol                      = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.public_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.public_lb_backend.id]
  probe_id                      = azurerm_lb_probe.public_lb_probe.id
}