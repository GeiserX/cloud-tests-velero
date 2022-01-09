#### GENERAL
variable "project_account_id" {
  default = "384894877891"
}

variable "region" {
  default = "eu-west-3"
}

variable "availability_zone" {
  default = {
    "0" = "eu-west-3a"
    #"1" = "eu-west-3b"
    #"2" = "eu-west-3c"
  }
}