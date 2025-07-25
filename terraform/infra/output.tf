
output "cosmosdb_mongodb_connection_string" {
  description = "The connection string for the MongoDB Cosmos DB account."
  # FIX: Changed to 'connection_strings[0]' as per azurerm provider version 3.64.0 documentation for MongoDB kind.
  value       = azurerm_cosmosdb_account.cosmosdb_mongodb.connection_strings[0]
  sensitive   = true
}

output "cosmosdb_workflow_connection_string" {
  description = "The connection string for the Workflow Cosmos DB account."
  # FIX: Changed to 'connection_strings[0]' as this attribute is available for all Cosmos DB kinds in provider version 3.64.0.
  value       = azurerm_cosmosdb_account.cosmosdb_workflow.connection_strings[0]
  sensitive   = true
}

output "servicebus_connection_string" {
  description = "The primary connection string for the Service Bus Namespace."
  value       = azurerm_servicebus_namespace.sb_namespace.default_primary_connection_string
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

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.logs.id
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.rg.name
}
