output "container_app_principal_id" {
  value = azurerm_container_app.ingestion.identity[0].principal_id
}
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}