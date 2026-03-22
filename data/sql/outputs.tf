output "sql_server_id" {
  value = azurerm_mssql_server.sql_server.id
}

output "sql_database_id" {
  value = azurerm_mssql_database.sql_database.id
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_name" {
  value = azurerm_mssql_database.sql_database.name
}
