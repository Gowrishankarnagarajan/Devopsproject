
# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "logs" {
  name                = "${var.prefix}-logs"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}

resource "random_string" "acr_suffix" {
  length  = 6
  upper   = false
  special = false
}

# Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}acr${random_string.acr_suffix.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  admin_enabled       = false
}

# Container App Environment
resource "azurerm_container_app_environment" "env" {
  name                       = "${var.prefix}-env"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
  # log_analytics_configuration {
  #   customer_id = azurerm_log_analytics_workspace.logs.customer_id
  #   shared_key  = azurerm_log_analytics_workspace.logs.primary_shared_key
  # }
}

# Container Apps (one example - repeat for others)
resource "azurerm_container_app" "ingestion" {
  name                         = "${var.prefix}-ingestion"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode                = "Single"

  template {
    container {
      name   = "ingestion"
      image  = "${azurerm_container_registry.acr.login_server}/ingestion:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }


  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

# Role Assignment to allow Container Apps to pull from ACR
resource "azurerm_role_assignment" "acr_pull_ingestion" {
  principal_id         = azurerm_container_app.ingestion.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
  depends_on           = [azurerm_container_app.ingestion]
}

# Diagnostics
resource "azurerm_monitor_diagnostic_setting" "diag_ingestion" {
  name                       = "diag-ingestion"
  target_resource_id         = azurerm_container_app.ingestion.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  enabled_log {
    category = "ContainerAppConsoleLogs"
    retention_policy {
      enabled = false
      days    = 0
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = false
      days    = 0
    }
  }
}
