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
  depends_on          = [azurerm_resource_group.rg]
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
  admin_enabled       = true
  depends_on          = [azurerm_resource_group.rg]
  identity {
    type = "SystemAssigned"
  }

}
