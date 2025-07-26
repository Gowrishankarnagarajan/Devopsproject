# terraform/apps/main.tf
# This file contains the main configuration for Azure Container Apps and related infrastructure

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# All the infrastructure resources that were previously in terraform/infra/main.tf
# are now moved here:

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "aca-logs-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name # Use the passed-in resource group
  sku                 = "PerGB2018"
  retention_in_days   = 30
  lifecycle {
    ignore_changes = []
  }
}

resource "azurerm_servicebus_namespace" "sb_namespace" {
  name                = "acasbns-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "ingestion_queue" {
  name         = "ingestion-queue"
  namespace_id = azurerm_servicebus_namespace.sb_namespace.id
}

resource "azurerm_servicebus_queue" "workflow_queue" {
  name         = "workflow-queue"
  namespace_id = azurerm_servicebus_namespace.sb_namespace.id
}

resource "azurerm_cosmosdb_account" "cosmosdb_mongodb" {
  name                = "acacosmosmongodb${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "MongoDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_account" "cosmosdb_workflow" {
  name                = "acacosmosworkflow${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_redis_cache" "redis_cache" {
  name                = "acaredis-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  minimum_tls_version = "1.2"
}

resource "azurerm_application_insights" "app_insights" {
  name                = "aca-appinsights-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.logs.id
}

resource "azurerm_key_vault" "key_vault" {
  name                        = "acakeyvault${random_string.suffix.result}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
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
  object_id    = data.azurerm_client_config.current.object_id
  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
  ]
  depends_on = [
    azurerm_key_vault.key_vault
  ]
}

resource "azurerm_key_vault_secret" "example_secret" {
  name         = "ExampleSecret"
  value        = "my-super-secret-value"
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.github_actions_sp_policy
  ]
}

# Container Apps Environment
resource "azurerm_container_app_environment" "env" {
  name                         = "aca-env-${var.resource_group_name_prefix}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  # Removed the 'container_registry' block with username/password
  # as we are now using a User-Assigned Managed Identity per app for ACR pull.
}

# Data source to fetch the ACR details for role assignment
data "azurerm_container_registry" "acr" {
  name                = split(".", var.acr_login_server)[0] # Extract ACR name from the login server URL
  resource_group_name = var.resource_group_name              # Assuming ACR is in the same resource group as other apps resources
}

# NEW: User-Assigned Managed Identity for ACR Pull
resource "azurerm_user_assigned_identity" "acr_pull_identity" {
  name                = "uami-acr-pull-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# NEW: Grant the User-Assigned Managed Identity AcrPull permission on the ACR
resource "azurerm_role_assignment" "acr_pull_uami_role" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_pull_identity.principal_id
  depends_on = [
    azurerm_user_assigned_identity.acr_pull_identity,
    data.azurerm_container_registry.acr # Explicit dependency on data source for clarity
  ]
}

# Ingestion Service Container App
resource "azurerm_container_app" "ingestion_service" {
  name                         = "ingestion-service-${var.resource_group_name_prefix}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  # Keep SystemAssigned for Key Vault access if needed
  identity {
    type = "SystemAssigned"
  }

  # NEW: Configure ACR pull using the User-Assigned Managed Identity
  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.acr_pull_identity.id
  }

  template {
    container {
      name   = "ingestion-container"
      image  = var.ingestion_image
      cpu    = 0.5
      memory = "1Gi" # CORRECTED: Changed from "1.0Gi" to "1Gi"
      env {
        name  = "SERVICEBUS_CONNECTION_STRING"
        value = azurerm_servicebus_namespace.sb_namespace.default_primary_connection_string # Reference local Service Bus
      }
      env {
        name  = "COSMOSDB_MONGODB_CONNECTION_STRING"
        value = azurerm_cosmosdb_account.cosmosdb_mongodb.connection_strings[0] # Reference local CosmosDB
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.app_insights.connection_string # Reference local App Insights
      }
      env {
        name  = "KEY_VAULT_URI"
        value = azurerm_key_vault.key_vault.vault_uri # Reference local Key Vault
      }
    }
    min_replicas = 1
    max_replicas = 5
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# REMOVED: azurerm_role_assignment for AcrPull for individual apps (now handled by UAMI)

# Workflow Service Container App
resource "azurerm_container_app" "workflow_service" {
  name                         = "workflow-service-${var.resource_group_name_prefix}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  # NEW: Configure ACR pull using the User-Assigned Managed Identity
  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.acr_pull_identity.id
  }

  template {
    container {
      name   = "workflow-container"
      image  = var.workflow_image
      cpu    = 0.5
      memory = "1Gi" # CORRECTED: Changed from "1.0Gi" to "1Gi"
      env {
        name  = "SERVICEBUS_CONNECTION_STRING"
        value = azurerm_servicebus_namespace.sb_namespace.default_primary_connection_string
      }
      env {
        name  = "COSMOSDB_WORKFLOW_CONNECTION_STRING"
        value = azurerm_cosmosdb_account.cosmosdb_workflow.connection_strings[0]
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.app_insights.connection_string
      }
      env {
        name  = "KEY_VAULT_URI"
        value = azurerm_key_vault.key_vault.vault_uri
      }
    }
    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = false
    target_port      = 8081
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Package Service Container App
resource "azurerm_container_app" "package_service" {
  name                         = "package-service-${var.resource_group_name_prefix}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  # NEW: Configure ACR pull using the User-Assigned Managed Identity
  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.acr_pull_identity.id
  }

  template {
    container {
      name   = "package-container"
      image  = var.package_image
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "COSMOSDB_MONGODB_CONNECTION_STRING"
        value = azurerm_cosmosdb_account.cosmosdb_mongodb.connection_strings[0]
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.app_insights.connection_string
      }
      env {
        name  = "KEY_VAULT_URI"
        value = azurerm_key_vault.key_vault.vault_uri
      }
    }
    min_replicas = 1
    max_replicas = 2
  }

  ingress {
    external_enabled = false
    target_port      = 8082
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Drone Scheduler Service Container App
resource "azurerm_container_app" "drone_scheduler_service" {
  name                         = "drone-scheduler-service-${var.resource_group_name_prefix}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  # NEW: Configure ACR pull using the User-Assigned Managed Identity
  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.acr_pull_identity.id
  }

  template {
    container {
      name   = "drone-scheduler-container"
      image  = var.drone_scheduler_image
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "REDIS_CONNECTION_STRING"
        value = azurerm_redis_cache.redis_cache.primary_connection_string
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.app_insights.connection_string
      }
      env {
        name  = "KEY_VAULT_URI"
        value = azurerm_key_vault.key_vault.vault_uri
      }
    }
    min_replicas = 1
    max_replicas = 2
  }

  ingress {
    external_enabled = false
    target_port      = 8083
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Delivery Service Container App
resource "azurerm_container_app" "delivery_service" {
  name                         = "delivery-service-${var.resource_group_name_prefix}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  # NEW: Configure ACR pull using the User-Assigned Managed Identity
  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.acr_pull_identity.id
  }

  template {
    container {
      name   = "delivery-container"
      image  = var.delivery_image
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "COSMOSDB_MONGODB_CONNECTION_STRING"
        value = azurerm_cosmosdb_account.cosmosdb_mongodb.connection_strings[0]
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.app_insights.connection_string
      }
      env {
        name  = "KEY_VAULT_URI"
        value = azurerm_key_vault.key_vault.vault_uri
      }
    }
    min_replicas = 1
    max_replicas = 2
  }

  ingress {
    external_enabled = true
    target_port      = 8084
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Set Key Vault Access Policies for each Container App's Managed Identity
# These policies remain, as they are for Key Vault access, not ACR image pull.
resource "azurerm_key_vault_access_policy" "ingestion_kv_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id # Reference local Key Vault
  tenant_id    = azurerm_container_app.ingestion_service.identity[0].tenant_id
  object_id    = azurerm_container_app.ingestion_service.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
  depends_on = [
    azurerm_container_app.ingestion_service
  ]
}

resource "azurerm_key_vault_access_policy" "workflow_kv_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id # Reference local Key Vault
  tenant_id    = azurerm_container_app.workflow_service.identity[0].tenant_id
  object_id    = azurerm_container_app.workflow_service.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
  depends_on = [
    azurerm_container_app.workflow_service
  ]
}

resource "azurerm_key_vault_access_policy" "package_kv_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id # Reference local Key Vault
  tenant_id    = azurerm_container_app.package_service.identity[0].tenant_id
  object_id    = azurerm_container_app.package_service.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
  depends_on = [
    azurerm_container_app.package_service
  ]
}

resource "azurerm_key_vault_access_policy" "drone_scheduler_kv_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id # Reference local Key Vault
  tenant_id    = azurerm_container_app.drone_scheduler_service.identity[0].tenant_id
  object_id    = azurerm_container_app.drone_scheduler_service.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
  depends_on = [
    azurerm_container_app.drone_scheduler_service
  ]
}

resource "azurerm_key_vault_access_policy" "delivery_kv_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id # Reference local Key Vault
  tenant_id    = azurerm_container_app.delivery_service.identity[0].tenant_id
  object_id    = azurerm_container_app.delivery_service.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
  depends_on = [
    azurerm_container_app.delivery_service
  ]
}