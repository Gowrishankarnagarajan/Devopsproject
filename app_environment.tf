resource "azurerm_container_app_environment" "acrenv" {
  name                = "${var.prefix}-acrenv"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  depends_on          = [azurerm_resource_group.rg]

  tags = {
    environment = "DevopsProject"
  }
}