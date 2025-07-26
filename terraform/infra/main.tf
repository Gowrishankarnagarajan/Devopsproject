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
  sku                 = "Basic" # Or "Standard", "Premium" based on your needs
  admin_enabled       = true    # Enabled for simpler programmatic access
  
  # Added for explicit dependency, though often implicitly handled
  depends_on = [ azurerm_resource_group.rg ] 

  # CORRECTED SYNTAX: The block name for managed identity is 'identity'
  identity { 
    type = "SystemAssigned"
  }
}

# Data source to get the current client's (GitHub Actions Service Principal) configuration
# This refers to the identity used by 'azure/login@v1' in your workflow.
data "azurerm_client_config" "current" {}

# Grant the Service Principal 'AcrPush' permissions on the ACR
# # This is crucial for the 'build-and-push-images' job to succeed.
# resource "azurerm_role_assignment" "acr_push_permission" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPush" # Allows pushing, pulling, and deleting images
#   principal_id         = data.azurerm_client_config.current.object_id # CORRECTED: Removed [0]
  
#   # Ensure the ACR is created before trying to assign a role on it
#   depends_on = [azurerm_container_registry.acr] 
# }