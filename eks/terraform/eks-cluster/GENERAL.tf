provider "aws" {
  region = var.region
}
### Provider for CDN Certificates
provider "aws" {
  alias = "paris"
  region = "eu-west-3"
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}