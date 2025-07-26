# C:\Karthik_Devops\Terraform\Devopsproject\terraform\infra\output.tf

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  description = "The login server for the Azure Container Registry."
  value       = azurerm_container_registry.acr.login_server
}

output "location" {
  description = "The Azure region where resources are deployed."
  value       = azurerm_resource_group.rg.location
}