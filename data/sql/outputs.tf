output "sql_server_id" {
  value = azurerm_mssql_server.sql_server.id
}

output "sql_database_id" {
  value = var.create_database ? azurerm_mssql_database.sql_database[0].id : null
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_name" {
  value = var.create_database ? azurerm_mssql_database.sql_database[0].name : null
}
