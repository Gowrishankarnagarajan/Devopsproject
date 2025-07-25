# terraform/infra/main.tf

# Terraform and Provider Configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = { # Ensure random provider is also declared if used
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}
}

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
  name                = "acaregistry${random_string.suffix.result}" # ACR names must be globally unique and alphanumeric
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
  capacity            = 1 # C0 Basic (smallest size)
  family              = "C"
  sku_name            = "Basic"
  # Corrected: Use 'non_ssl_port_enabled' instead of 'enable_non_ssl_port'
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

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_secret" "example_secret" {
  name         = "ExampleSecret"
  value        = "my-super-secret-value"
  key_vault_id = azurerm_key_vault.key_vault.id
}
