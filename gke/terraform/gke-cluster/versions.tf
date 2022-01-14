terraform {
  required_version = ">= 0.14"

  backend "local" {
    path = "terraform.tfstate"
  }


  required_providers {

    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 3.59.0"
    }
  }
}

