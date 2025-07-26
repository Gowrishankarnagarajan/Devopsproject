# C:\Karthik_Devops\Terraform\Devopsproject\terraform\infra\variables.tf

variable "location" {
  description = "The Azure region to deploy resources."
  type        = string
  default     = "uksouth" # You can change this to your preferred region
}