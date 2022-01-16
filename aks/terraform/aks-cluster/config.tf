# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
#====================
# Project variables
#====================
variable "gcp_project_id" {
  default = "claranet-playground"
}

variable "gcp_default_region" {
  default = "europe-west1"
}

variable "gcp_default_zone" {
  default = "europe-west1-b"
}
