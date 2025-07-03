resource "azurerm_mssql_server" "db_server" {
  name                         = "dbserver-sql"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = "P@ssw0rd1234!"
}

resource "azurerm_mssql_database" "db" {
  name                = "appdb"
  server_id           = azurerm_mssql_server.db_server.id
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  sku_name            = "Basic"
}

resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "sql-db-private-endpoint"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.DB[0].id

  private_service_connection {
    name                           = "sql-db-privateserviceconnection"
    private_connection_resource_id = azurerm_mssql_server.db_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "sql-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

resource "azurerm_private_dns_a_record" "sql_dns_a_record" {
  name                = azurerm_mssql_server.db_server.name
  zone_name           = azurerm_private_dns_zone.sql_dns.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_private_endpoint.private_service_connection[0].private_ip_address]
}
