#===========================
# Config for the platform services part
#===========================

#==================
# Provider config
#==================

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_default_region
  zone    = var.gcp_default_zone
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