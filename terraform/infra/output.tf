# terraform/infra/outputs.tf

output "acr_login_server" {
  description = "The login server URL for the Azure Container Registry."
  value       = azurerm_container_registry.acr.login_server
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.logs.id
}

output "resource_group_name" {
  description = "The name of the resource group created."
  value       = azurerm_resource_group.rg.name
}

output "location" {
  description = "The Azure region where resources are deployed."
  value       = azurerm_resource_group.rg.location
}

output "servicebus_namespace_name" {
  description = "The name of the Service Bus Namespace."
  value       = azurerm_servicebus_namespace.sb_namespace.name
}

output "servicebus_connection_string" {
  description = "The primary connection string for the Service Bus Namespace (RootManageSharedAccessKey)."
  value       = azurerm_servicebus_namespace.sb_namespace.default_primary_connection_string
  sensitive   = true
}

output "cosmosdb_mongodb_connection_string" {
  description = "The connection string for the MongoDB API Cosmos DB account."
  # Corrected: Use 'primary_mongodb_connection_string'
  value       = azurerm_cosmosdb_account.cosmosdb_mongodb.primary_mongodb_connection_string
  sensitive   = true
}

output "cosmosdb_workflow_connection_string" {
  description = "The connection string for the Workflow Cosmos DB account."
  # Corrected: Use 'primary_sql_connection_string' for GlobalDocumentDB (SQL API)
  value       = azurerm_cosmosdb_account.cosmosdb_workflow.primary_sql_connection_string
  sensitive   = true
}

output "redis_connection_string" {
  description = "The primary connection string for the Redis Cache."
  value       = azurerm_redis_cache.redis_cache.primary_connection_string
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The connection string for Application Insights."
  value       = azurerm_application_insights.app_insights.connection_string
  sensitive   = true
}

output "key_vault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.key_vault.vault_uri
}

output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.key_vault.id
}
