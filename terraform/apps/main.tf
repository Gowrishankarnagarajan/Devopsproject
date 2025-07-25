# terraform/apps/main.tf
# This file contains the main configuration for Azure Container Apps
# It defines the Container Apps environment and individual services
resource "azurerm_container_app_environment" "env" {
  name                       = "aca-env-${var.resource_group_name_prefix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  # infrastructure_subnet_id     = null # Optional, for VNet integration
}

# Ingestion Service Container App
resource "azurerm_container_app" "ingestion_service" {
  name                         = "ingestion-service-${var.resource_group_name_prefix}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  # Managed Identity for accessing Key Vault and other Azure services
  identity {
    type = "SystemAssigned"
  }

  template {
    container {
      name   = "ingestion-container"
      image  = var.ingestion_image
      cpu    = 0.5
      memory = "1.0Gi"
      env {
        name  = "SERVICEBUS_CONNECTION_STRING"
        value = var.servicebus_connection_string
      }
      env {
        name  = "COSMOSDB_MONGODB_CONNECTION_STRING"
        value = var.cosmosdb_mongodb_connection_string
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = var.application_insights_connection_string
      }
      env {
        name  = "KEY_VAULT_URI"
        value = var.key_vault_uri
      }
    }
    # FIX: For azurerm provider version 3.64.0, min_replicas and max_replicas
    # are direct attributes of the 'template' block. The 'replica' and 'scale'
    # blocks for advanced scaling were introduced in later versions.
    min_replicas = 1
    max_replicas = 5
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    # FIX: Changed "Auto" to "auto" as required by the provider schema
    transport = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Workflow Service Container App
resource "azurerm_container_app" "workflow_service" {
  name                         = "workflow-service-${var.resource_group_name_prefix}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  template {
    container {
      name   = "workflow-container"
      image  = var.workflow_image
      cpu    = 0.5
      memory = "1.0Gi"
      env {
        name  = "SERVICEBUS_CONNECTION_STRING"
        value = var.servicebus_connection_string
      }
      env {
        name  = "COSMOSDB_WORKFLOW_CONNECTION_STRING"
        value = var.cosmosdb_workflow_connection_string
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = var.application_insights_connection_string
      }
      env {
        name  = "KEY_VAULT_URI"
        value = var.key_vault_uri
      }
    }
    # FIX: For azurerm provider version 3.64.0, min_replicas and max_replicas
    # are direct attributes of the 'template' block.
    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = false
    target_port      = 8081
    # FIX: Changed "Auto" to "auto" as required by the provider schema
    transport = "auto"
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

  template {
    container {
      name   = "package-container"
      image  = var.package_image
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "COSMOSDB_MONGODB_CONNECTION_STRING"
        value = var.cosmosdb_mongodb_connection_string
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = var.application_insights_connection_string
      }
      env {
        name  = "KEY_VAULT_URI"
        value = var.key_vault_uri
      }
    }
    # FIX: For azurerm provider version 3.64.0, min_replicas and max_replicas
    # are direct attributes of the 'template' block.
    min_replicas = 1
    max_replicas = 2
  }

  ingress {
    external_enabled = false
    target_port      = 8082
    # FIX: Changed "Auto" to "auto" as required by the provider schema
    transport = "auto"
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

  template {
    container {
      name   = "drone-scheduler-container"
      image  = var.drone_scheduler_image
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "REDIS_CONNECTION_STRING"
        value = var.redis_connection_string
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = var.application_insights_connection_string
      }
      env {
        name  = "KEY_VAULT_URI"
        value = var.key_vault_uri
      }
    }
    # FIX: For azurerm provider version 3.64.0, min_replicas and max_replicas
    # are direct attributes of the 'template' block.
    min_replicas = 1
    max_replicas = 2
  }

  ingress {
    external_enabled = false
    target_port      = 8083
    # FIX: Changed "Auto" to "auto" as required by the provider schema
    transport = "auto"
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

  template {
    container {
      name   = "delivery-container"
      image  = var.delivery_image
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "COSMOSDB_MONGODB_CONNECTION_STRING"
        value = var.cosmosdb_mongodb_connection_string
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = var.application_insights_connection_string
      }
      env {
        name  = "KEY_VAULT_URI"
        value = var.key_vault_uri
      }
    }
    # FIX: For azurerm provider version 3.64.0, min_replicas and max_replicas
    # are direct attributes of the 'template' block.
    min_replicas = 1
    max_replicas = 2
  }

  ingress {
    external_enabled = false
    target_port      = 8084
    # FIX: Changed "Auto" to "auto" as required by the provider schema
    transport = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}


# Set Key Vault Access Policies for each Container App's Managed Identity
# This grants the Container App's system-assigned managed identity permissions to Key Vault
resource "azurerm_key_vault_access_policy" "ingestion_kv_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_container_app.ingestion_service.identity[0].tenant_id
  object_id    = azurerm_container_app.ingestion_service.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

resource "azurerm_key_vault_access_policy" "workflow_kv_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_container_app.workflow_service.identity[0].tenant_id
  object_id    = azurerm_container_app.workflow_service.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

resource "azurerm_key_vault_access_policy" "package_kv_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_container_app.package_service.identity[0].tenant_id
  object_id    = azurerm_container_app.package_service.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

resource "azurerm_key_vault_access_policy" "drone_scheduler_kv_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_container_app.drone_scheduler_service.identity[0].tenant_id
  object_id    = azurerm_container_app.drone_scheduler_service.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

resource "azurerm_key_vault_access_policy" "delivery_kv_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_container_app.delivery_service.identity[0].tenant_id
  object_id    = azurerm_container_app.delivery_service.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
}
