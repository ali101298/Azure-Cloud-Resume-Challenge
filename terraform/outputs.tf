output resource_group_name {
  description = "Name of the resource group"
  value = azurerm_resource_group.acrc_resource_group.name
}

output "storage_account_name" {
    description = "Name of the storage account"
    value = azurerm_storage_account.acrc_website.name
}

output "website_url" {
    description = "Website URL"
    value = azurerm_storage_account.acrc_website.primary_web_endpoint
}

output "cdn_endpoint_url" {
    description = "CDN endpoint URL"
    value = "https://${azurerm_cdn_endpoint.alizamin.fqdn}"
}

output "function_app_name" {
    description = "Name of the Function App"
    value = azurerm_linux_function_app.acrc_visitor_counter.name
}

output "function_app_url" {
    description = "Function App URL"
    value = "https://${azurerm_linux_function_app.acrc_visitor_counter.default_hostname}"
}

output "cosmosdb_account_name" {
    description = "CosmosDB account name"
    value = azurerm_cosmosdb_account.acrc_cosmosdb_account.name
}

output "cosmosdb_endpoint" {
    description = "CosmosDB endpoint"
    value = azurerm_cosmosdb_account.acrc_cosmosdb_account.endpoint
}