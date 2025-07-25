resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

resource "azurerm_resource_group" "rg" {
  name     = "aca-rg-${random_string.suffix.result}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "aca-logs-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_registry" "acr" {
  name                = "acaregistry${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_servicebus_namespace" "sb_namespace" {
  name                = "acasbns-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "ingestion_queue" {
  name                = "ingestion-queue"
  namespace_id        = azurerm_servicebus_namespace.sb_namespace.id
  partitioning_enabled = false
}

resource "azurerm_servicebus_queue" "workflow_queue" {
  name                = "workflow-queue"
  namespace_id        = azurerm_servicebus_namespace.sb_namespace.id
  partitioning_enabled = false
}

resource "azurerm_cosmosdb_account" "cosmosdb_mongodb" {
  name                = "acacosmosmongodb${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "MongoDB"
  
  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_account" "cosmosdb_workflow" {
  name                = "acacosmosworkflow${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  
  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

resource "azurerm_redis_cache" "redis_cache" {
  name                = "acaredis-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  non_ssl_port_enabled = false
  minimum_tls_version = "1.2"
}

resource "azurerm_application_insights" "app_insights" {
  name                = "aca-appinsights-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.logs.id
}

resource "azurerm_key_vault" "key_vault" {
  name                        = "acakeyvault${random_string.suffix.result}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = false
  purge_protection_enabled    = false
}

# Data source to get the current client's (GitHub Actions Service Principal) configuration
data "azurerm_client_config" "current" {}

# Grant the GitHub Actions Service Principal (current client) permissions on the Key Vault
resource "azurerm_key_vault_access_policy" "github_actions_sp_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id # The OID from the error message

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore" # Full secret management
  ]
  # You can add other permissions (e.g., "Get", "List" for keys/certificates) if needed
}


resource "azurerm_key_vault_secret" "example_secret" {
  name         = "ExampleSecret"
  value        = "my-super-secret-value"
  key_vault_id = azurerm_key_vault.key_vault.id
}
