resource "azurerm_network_interface" "PrivateNIC" {
  name                = "PrivateNIC1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Private[0].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "PrivateVM" {
  name                = "PrivateVM1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "P@ssw0rd1234!"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.PrivateNIC.id,
  ]

  os_disk {
    name                 = "privateserver-osdisk-vm"
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

  provisioner "file" {
    source      = "${path.module}/app.js"
    destination = "/home/azureuser/app.js"
  }

  provisioner "remote-exec" {
    inline = [
      # Update and install curl if missing
      "sudo apt-get update -y",
      "sudo apt-get install -y curl",
      # Install Node.js 18.x
      "curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      # Go to home directory
      "cd /home/azureuser",
      # Create package.json if not exists
      "[ -f package.json ] || npm init -y",
      # Install express
      "npm install express",
      # Start the app in the background
      "nohup node app.js > app.log 2>&1 &"
    ]
  }

  connection {
    type        = "ssh"
    user        = "azureuser"
    password    = "P@ssw0rd1234!"
    host        = self.private_ip_address
    timeout     = "2m"
  }
}