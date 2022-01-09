provider "aws" {
  region = var.region
}
### Provider for CDN Certificates
provider "aws" {
  alias = "ireland"
  region = "eu-west-3"
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}