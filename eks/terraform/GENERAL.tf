provider "aws" {
  region = var.region
}
### Provider for CDN Certificates
provider "aws" {
  alias = "ireland"
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "inform-klm-dev-terraform-state"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}