# C:\Karthik_Devops\Terraform\Devopsproject\terraform\infra\main.tf

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

resource "azurerm_container_registry" "acr" {
  name                = "acaregistry${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true # Keep this enabled for easier programmatic access
  depends_on          = [azurerm_resource_group.rg]

  # CORRECTED: The block name should be 'identity', not 'system_assigned_identity'
  identity {
    type = "SystemAssigned"
  }
}

# Data source to get the current client's (GitHub Actions Service Principal) configuration
data "azurerm_client_config" "current" {}

# Grant the Service Principal (GitHub Actions Identity) 'AcrPush' permissions on the ACR
resource "azurerm_role_assignment" "acr_push_permission" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush" # Allows pushing, pulling, and deleting images
  principal_id         = data.azurerm_client_config.current.object_id[0] # Use the first object_id if multiple are returned

  # Ensure the ACR is created before trying to assign a role on it
  depends_on = [azurerm_container_registry.acr]
}