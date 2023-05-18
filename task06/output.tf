output "sorage_accout_table_id" {
  description = "sql_table_id"
  value       = azurerm_storage_table.table1_resource.id
}

output "sql_username" {
  value = azurerm_postgresql_server.sqlserver_resource.administrator_login
}  

output "sql_password" {
  value = nonsensitive(azurerm_postgresql_server.sqlserver_resource.administrator_login_password)
} 
 
output "sql_fqdn" {
  value = azurerm_postgresql_server.sqlserver_resource.fqdn
}
