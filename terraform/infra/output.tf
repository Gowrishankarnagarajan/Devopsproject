# C:\Karthik_Devops\Terraform\Devopsproject\terraform\infra\output.tf

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.rg.name
}

output "location" {
  description = "The Azure region where resources are deployed."
  value       = azurerm_resource_group.rg.location
}

output "acr_login_server" {
  description = "The login server for the Azure Container Registry."
  value       = azurerm_container_registry.acr.login_server
}

# Remove all other outputs (Service Bus, CosmosDB, Redis, App Insights, Key Vault IDs/URIs)
# from this file. They will be outputs or internally managed by the terraform/apps module.