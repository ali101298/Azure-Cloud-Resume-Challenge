/* 
Creating all the Azure infrastructure here:

Storage Account for static website hosting
CosmosDB for visitor counter data
Function App for Python API
CDN for global distribution and HTTPS
*/

# Random suffix for unique naming
resource "random_string" "suffix" {
    length = 8
    special = false
    upper = false
}

# configuring resource group
resource "azurerm_resource_group" "acrc_resource_group" {
    name = "rg-${var.project_name}-${var.environment}"
    location = var.location
    tags = var.tags
}

# configuring storage account for static website
resource "azurerm_storage_account" "acrc_website" {
    name = "st${replace(var.project_name, "-", "")}${random_string.suffix.result}"
    resource_group_name = azurerm_resource_group.acrc_resource_group.name
    location = azurerm_resource_group.acrc_resource_group.location
    account_tier = "Standard"
    account_replication_type = "LRS"
    account_kind = StorageV2

    static_website {
        index_document = "index.html"
    }

    tags = var.tags
}

# configuring CosmosDB account
resource "azurerm_cosmosdb_account" "acrc_cosmosdb_account" {
    name = "cosmos-${var.project_name}-${random_string.suffix.result}"
    location = azurerm_resource_group.acrc_resource_group.location
    resource_group_name = resource_group_name.acrc_resource_group.name
    offer_type = "Standard"
    kind = "GlobalDocumentDB"

    enable_automatic_failover = false
    enable_free_tier = true

    capabilities {
        name = "EnableServerless"
    }

    capabilities {
        name = "EnableTable"
    }

    consistency_policy {
        consistency_level "Session"
    }

    geo_location {
        location = azurerm_resource_group.acrc_resource_group.location
        failover_priority = 0
    }

    tags = var.tags
}

# Configuring CosmosDB Table for visitor counter
resource "azurerm_cosmosdb_table" "acrc_cosmos_table" {
    name = "VisitorCounter"
    resource_group_name = resource_group_name.acrc_resource_group.name
    account_name = azurerm_cosmosdb_account.acrc_cosmosdb_account.name
    throughput = "400"
} 

# Configuring Functions App service plan
resource "azurerm_service_plan" "acrc_func" {
    name = "functions-plan-${var.project_name}-${var.environment}"
    resource_group_name = azurerm_resource_group.acrc_resource_group.name
    location = azurerm_resource_group.acrc_resource_group.location
    os_type = "Linux"
    sku_name = "Y1" # Consumption plan

    tags = var.tags
}

# Storage Account for Function App
resource "azurerm_storage_account" "acrc_func_sa" {
    name = "stfunc${replace(var.project_name, "-", "")}${random_string.suffix.result}"
    resource_group_name = azurerm_resource_group.acrc_resource_group.name
    location = azurerm_resource_group.acrc_resource_group.location
    account_tier = "Standard"
    account_replication_type = "LRS"

    tags = var.tags
}

# Configuring Function App
resource "azurerm_linux_function_app" "acrc_visitor_counter" {
    name = "func-${var.project_name}-${random_string.suffix.result}"
    resource_group_name = azurerm_resource_group.acrc_resource_group.name
    location = azurerm_resource_group.acrc_resource_group.location

    storage_account_name = azurerm_storage_account.acrc_func_sa.name
    storage_account_access_key = azurerm_storage_account.acrc_func_sa.primary_access_key
    service_plan_id = azurerm_service_plan.acrc_func.id

    site_config {
        application_stack {
            python_version = "3.11"
        }

        cors {
            allowed_origins = ["*"]
            support_credentials = false
        }
    }

    app_settings = {
        "FUNCTIONS_WORKER_RUNTIME" = "python"
        "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
        "COSMOS_DB_CONNECTION_STRING" = azurerm_cosmosdb_account.acrc_cosmosdb_account.connection_strings[0]
        "COSMOS_DB_DATABASE_NAME" = azurerm_cosmosdb_account.acrc_cosmosdb_account.name
        "COSMOS_DB_CONTAINER_NAME" = azurerm_cosmosdb_table.acrc_cosmos_table.name
    }

    tags = var.tags
}

# CDN profile
resource "azurerm_cdn_profile" "acrc_cdn_profile" {
    name = "cdn-prof-${var.project_name}-${var.environment}"
    location = azurerm_resource_group.acrc_resource_group.location
    resource_group_name = azurerm_resource_group.acrc_resource_group.name
    sku = "Standard_Microsoft"

    tags = var.tags
}

# CDN Endpoint
resource "azurerm_cdn_endpoint" "acrc_website" {
    name = "cdn-site-${var.project_name}-${random_string.suffix.result}"
    profile_name = azurerm_cdn_endpoint.acrc_cdn_profile.name
    location = azurerm_resource_group.acrc_resource_group.location
    resource_group_name = azurerm_resource_group.acrc_resource_group.name

    origin {
        name = "acrc_website_origin"
        host_name = azurerm_storage_account.acrc_website.primary_web_host
    }

    tags.var
}