#### Create resource group ####
resource "azurerm_resource_group" "rg_resource" {
  name     = "task6"
  location = "West Europe"
}


#### Create storage account ####
resource "azurerm_storage_account" "st_resource" {
  name                     = "st00task06"
  resource_group_name      = azurerm_resource_group.rg_resource.name
  location                 = azurerm_resource_group.rg_resource.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  depends_on = [
    azurerm_resource_group.rg_resource
  ]
}

#### Create table in storage account ####
resource "azurerm_storage_table" "table1_resource" {
  name                 = "table1"
  storage_account_name = azurerm_storage_account.st_resource.name
    
   depends_on = [
    azurerm_storage_account.st_resource
  ]
}

#### Generate random password for sql server ####
resource "random_password" "main" {
  length      = 12
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false
 
  keepers = {
    administrator_login_password = var.sqlserver_name
  }
}

#### Create postgresql server ####
resource "azurerm_postgresql_server" "sqlserver_resource" {
  name                = var.sqlserver_name
  resource_group_name = azurerm_resource_group.rg_resource.name
  location            = azurerm_resource_group.rg_resource.location

  sku_name = "B_Gen5_1"
  storage_mb                    = 5120
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  auto_grow_enabled             = false

  administrator_login           = var.admin_username
  administrator_login_password  = var.admin_password == null ? random_password.main.result : var.admin_password
  version                       = "9.5"
  public_network_access_enabled = true
  ssl_enforcement_enabled		= true

  depends_on = [
    azurerm_resource_group.rg_resource
  ]
}

#### Create postgresql database ####
resource "azurerm_postgresql_database" "db_resource" {
  name                = var.database_name
  resource_group_name = azurerm_resource_group.rg_resource.name
  server_name         = azurerm_postgresql_server.sqlserver_resource.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  depends_on = [
    azurerm_postgresql_server.sqlserver_resource
  ]
}

#### Create postgresql firewall rule ####
resource "azurerm_postgresql_firewall_rule" "psqlfw_resource" {
  name                = "sqlfwrule01"
  resource_group_name = azurerm_resource_group.rg_resource.name
  server_name         = azurerm_postgresql_server.sqlserver_resource.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"

  depends_on = [
    azurerm_postgresql_server.sqlserver_resource
  ]
}
