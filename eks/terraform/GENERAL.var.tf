#### GENERAL
variable "project_account_id" {
  default = "861693724544"
}
variable "project_name" {
  default = "inform-klm"
}
variable "environment" {
  default = "dev"
}

variable "region" {
  default = "eu-west-1"
}

variable "availability_zone" {
  default = {
    "0" = "eu-west-1a"
    "1" = "eu-west-1b"
    "2" = "eu-west-1c"
  }
}