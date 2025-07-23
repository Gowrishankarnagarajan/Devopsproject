resource "azurerm_container_app" "delivery" {
  name                         = "delivery-service"
  container_app_environment_id = azurerm_container_app_environment.acrenv.id
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  revision_mode                = "Single"

  template {
    container {
      name   = "delivery"
      image  = "${azurerm_container_registry.acr.login_server}/delivery:latest"
      cpu    = 0.5
      memory = "1.0Gi"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_container_registry.acr,
    azurerm_container_app_environment.acrenv
  ]

  tags = {
    environment = "DevopsProject"
  }
}