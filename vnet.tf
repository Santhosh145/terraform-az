resource "azurerm_virtual_network" "main" {
  name                = "Test_VNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "Public" {
  count                = 2
  name                 = "Public_Subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [
    count.index == 0 ? "10.0.10.0/24" : "10.0.20.0/24"
  ]
  depends_on           = [azurerm_virtual_network.main]
}

resource "azurerm_subnet" "Private" {
  count                = 2
  name                 = "Private_Subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [
    count.index == 0 ? "10.0.30.0/24" : "10.0.40.0/24"
  ]
  depends_on           = [azurerm_virtual_network.main]
}

resource "azurerm_subnet" "DB" {
  count                = 2
  name                 = "DB_Subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [
    count.index == 0 ? "10.0.50.0/24" : "10.0.60.0/24"
  ]
  depends_on           = [azurerm_virtual_network.main]
}