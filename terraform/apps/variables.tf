# terraform/apps/variables.tf

variable "location" {
  description = "The Azure region where the Container Apps environment will be deployed."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the Container App environment will be created."
  type        = string
}

variable "resource_group_name_prefix" {
  description = "A prefix derived from the resource group name for unique resource naming."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace for Container Apps logging."
  type        = string
}

variable "acr_login_server" {
  description = "The login server URL for the Azure Container Registry."
  type        = string
}

variable "servicebus_namespace_name" {
  description = "The name of the Service Bus Namespace."
  type        = string
}

variable "servicebus_connection_string" {
  description = "The primary connection string for the Service Bus Namespace."
  type        = string
  sensitive   = true
}

variable "cosmosdb_mongodb_connection_string" {
  description = "The connection string for the MongoDB API Cosmos DB account."
  type        = string
  sensitive   = true
}

variable "cosmosdb_workflow_connection_string" {
  description = "The connection string for the Workflow Cosmos DB account."
  type        = string
  sensitive   = true
}

variable "redis_connection_string" {
  description = "The primary connection string for the Redis Cache."
  type        = string
  sensitive   = true
}

variable "application_insights_connection_string" {
  description = "The connection string for Application Insights."
  type        = string
  sensitive   = true
}

variable "key_vault_uri" {
  description = "The URI of the Key Vault."
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Key Vault (needed for access policies)."
  type        = string
}

variable "ingestion_image" {
  description = "The full Docker image name for the Ingestion service."
  type        = string
}

variable "workflow_image" {
  description = "The full Docker image name for the Workflow service."
  type        = string
}

variable "package_image" {
  description = "The full Docker image name for the Package service."
  type        = string
}

variable "drone_scheduler_image" {
  description = "The full Docker image name for the Drone Scheduler service."
  type        = string
}

variable "delivery_image" {
  description = "The full Docker image name for the Delivery service."
  type        = string
}
