# terraform/apps/outputs.tf

output "ingestion_fqdn" {
  description = "The fully qualified domain name of the Ingestion Container App."
  value       = azurerm_container_app.ingestion_service.ingress[0].fqdn
}

output "workflow_fqdn_internal" {
  description = "The internal fully qualified domain name of the Workflow Container App."
  value       = azurerm_container_app.workflow_service.ingress[0].fqdn
}

output "package_fqdn_internal" {
  description = "The internal fully qualified domain name of the Package Container App."
  value       = azurerm_container_app.package_service.ingress[0].fqdn
}

output "drone_scheduler_fqdn_internal" {
  description = "The internal fully qualified domain name of the Drone Scheduler Container App."
  value       = azurerm_container_app.drone_scheduler_service.ingress[0].fqdn
}

output "delivery_fqdn_internal" {
  description = "The internal fully qualified domain name of the Delivery Container App."
  value       = azurerm_container_app.delivery_service.ingress[0].fqdn
}
