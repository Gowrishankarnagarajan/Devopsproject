variable "prefix" {
  type    = string
  default = "gs"
}


variable "location" {
  type    = string
  default = "UK South"
}
variable "acr_login_server" {
  description = "The login server for the Azure Container Registry."
  type        = string
  # You can optionally add a default value or make it sensitive if needed.
  # default     = "yourdefault.azurecr.io"
  # sensitive   = true
}