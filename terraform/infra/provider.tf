
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.64.0"
    }
  }
}

provider "azurerm" {
  features {}
  # FIX: Added skip_provider_registration to address the Microsoft.Media registration error.
  # This tells Terraform not to automatically register resource providers.
  skip_provider_registration = true
}