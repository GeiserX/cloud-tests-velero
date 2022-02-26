#===========================
# Config for the gke cluster part
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

# GKE Settings
# --------------------------

locals {
  vpc = {
    node_subnet_ip_range    = "10.162.0.0/22"
    pod_subnet_ip_range     = "10.42.0.0/16"
    service_subnet_ip_range = "10.143.0.0/23"
    pod_subnet_name         = "gke-pod-alias-ips"
  }

  node_nat_ports_per_vm   = 1024
  pod_nat_ports_per_vm    = 64


  fw_mgmt_sources         = ["0.0.0.0/0"]

  cluster = {
      name                   = "sergio-test"
      min_master_version     = "1.21.6-gke.1500"
      master_ipv4_cidr_block = "172.16.0.32/28"
      daily_maintenance      = "03:00"
      tags                   = ["gke-test"]
      node_disk_size_gb      = 20
      node_disk_type         = "pd-standard"
      node_image_type        = "COS"
      node_permissions       = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  preemtible = {
    node_version       = "1.21.5-gke.1302"
    initial_node_count = 1
    machine_type       = "n2-standard-2"
  }
}


