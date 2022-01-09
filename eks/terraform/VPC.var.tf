#### VPC
variable "vpc_name" {
  default = "sergio-test"
}
variable "vpc_cidr" {
  default = "172.20.0.0/21"

}

#### SUBNETS
variable "subnet_public" {
  default = "public"
}
variable "public_cidr" {
  default = {

    "eu-west-3a" = {
      availability_zone    = "eu-west-3a"
      cidr_block           = "172.20.4.0/24"
      availability_zone_id = "euw3-az1"
    }
    "eu-west-3b" = {
      availability_zone    = "eu-west-3b"
      cidr_block           = "172.20.5.0/24"
      availability_zone_id = "euw3-az2"
    }
  }
}
variable "subnet_private" {
  default = "private"
}
variable "private_cidr" {
  default = {

    "eu-west-3a" = {
      availability_zone    = "eu-west-3a"
      cidr_block           = "172.20.6.0/24"
      availability_zone_id = "euw3-az1"
    }
    "eu-west-3b" = {
      availability_zone    = "eu-west-3b"
      cidr_block           = "172.20.7.0/26"
      availability_zone_id = "euw3-az2"
    }
  }
}