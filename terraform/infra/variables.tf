# terraform/infra/variables.tf

variable "location" {
  description = "The Azure region to deploy resources."
  type        = string
  default     = "uksouth" # You can change this to your preferred region
}

# Remove the following block if it exists:

variable "acr_login_server" {
  description = "The login server URL for the Azure Container Registry."
  type        = string
}
