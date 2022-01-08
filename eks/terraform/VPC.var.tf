#### VPC
variable "vpc_name" {
  default = "Inform-KLM-DEV"
}
variable "vpc_cidr" {
  default = "172.20.4.0/24"

}

variable "vpc_peering_claranet" {
  default = {
    name              = "Claranet"
    peer_owner_id     = "834305427166"
    peer_vpc_id       = "vpc-0bda07fb9534802d0"
    peer_region       = "eu-central-1"
  }
}

#### SUBNETS
variable "subnet_public" {
  default = "public"
}
variable "public_cidr" {
  default = {

    "eu-west-1a" = {
      availability_zone    = "eu-west-1a" 
      cidr_block           = "172.20.4.0/26"
      availability_zone_id = "euw1-az1"
    }
    "eu-west-1b" = {
      availability_zone    = "eu-west-1b" 
      cidr_block           = "172.20.4.64/26"
      availability_zone_id = "euw1-az2"
    }
  }
}
variable "subnet_private" {
  default = "private"
}
variable "private_cidr" {
  default = {

    "eu-west-1a" = {
      availability_zone    = "eu-west-1a" 
      cidr_block           = "172.20.4.128/26"
      availability_zone_id = "euw1-az1"
    }
    "eu-west-1b" = {
      availability_zone    = "eu-west-1b" 
      cidr_block           = "172.20.4.192/26"
      availability_zone_id = "euw1-az2"
    }
  }
}


#### VPN
variable "vpn_route_default" {
  default = {
    "0" = "80.149.134.30/32"
  }
}
variable "vpn_route_klm" {
  default = {
    "0" = "171.21.122.254/32"
  }
}

variable "vpn_gateway_name" {
  default = "VPN-Gateway"
}

variable "vpn_customer_gateway" {
  default = {
    "Inform" = "193.98.224.244",
    "KLM"    = "171.21.80.230"
  }
}

variable "vpn_connection_name" {
  default = {
    "0" = "VPN-to-Inform"
    "1" = "VPN-to-KLM"
  }
}
