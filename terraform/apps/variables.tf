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

variable "acr_login_server" {
  description = "The login server URL for the Azure Container Registry."
  type        = string
}

# Remove all these variables as their corresponding resources are now in apps/main.tf
/*
variable "log_analytics_workspace_id" { ... }
variable "servicebus_namespace_name" { ... }
variable "servicebus_connection_string" { ... }
variable "cosmosdb_mongodb_connection_string" { ... }
variable "cosmosdb_workflow_connection_string" { ... }
variable "redis_connection_string" { ... }
variable "application_insights_connection_string" { ... }
variable "key_vault_uri" { ... }
variable "key_vault_id" { ... }
*/

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