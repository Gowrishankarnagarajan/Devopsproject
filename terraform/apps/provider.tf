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
  # Add this line to skip automatic provider registration
  skip_provider_registration = true
}
