resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_name
  }
}
resource "aws_vpc_peering_connection" "claranet" {
  vpc_id        = aws_vpc.default.id
  peer_owner_id = var.vpc_peering_claranet["peer_owner_id"]
  peer_vpc_id   = var.vpc_peering_claranet["peer_vpc_id"]
  peer_region   = var.vpc_peering_claranet["peer_region"]
    tags = {
      Name = var.vpc_peering_claranet["name"]
    }
}

### SUBNETS

resource "aws_subnet" "public" {
  for_each = var.public_cidr
  vpc_id                  = aws_vpc.default.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = "true"
  availability_zone_id    = each.value.availability_zone_id
  tags = {
    Name = var.subnet_public
  }
}

resource "aws_subnet" "private" {
  for_each = var.private_cidr
  vpc_id                  = aws_vpc.default.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = "false"
  availability_zone_id    = each.value.availability_zone_id
  tags = {
    Name = var.subnet_private
  }
}


### VPN
resource "aws_vpn_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = var.vpn_gateway_name
  }
}

resource "aws_customer_gateway" "default" {
  for_each = var.vpn_customer_gateway
  bgp_asn    = 65000
  ip_address = each.value
  type       = "ipsec.1"
  tags = {
    Name = each.key
  }
}

resource "aws_vpn_connection" "default" {
  vpn_gateway_id      = aws_vpn_gateway.default.id
  customer_gateway_id = aws_customer_gateway.default["Inform"].id
  type                = "ipsec.1"
  tunnel1_phase1_dh_group_numbers = ["2","14","19","20","24"]
  tunnel1_phase1_integrity_algorithms =  ["SHA1","SHA2-256","SHA2-384","SHA2-512"]
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase2_integrity_algorithms =  ["SHA1","SHA2-256","SHA2-384","SHA2-512"]
  tunnel1_phase2_encryption_algorithms = ["AES256"]
  tunnel1_phase2_dh_group_numbers = ["2","14","19","20","24"]
  tunnel1_ike_versions = ["ikev1","ikev2"]
  tunnel1_dpd_timeout_action = "restart"
  tunnel1_startup_action = "start"
  
  tunnel2_phase1_dh_group_numbers = ["2","14","19","20","24"]
  tunnel2_phase1_integrity_algorithms =  ["SHA1","SHA2-256","SHA2-384","SHA2-512"]
  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase2_integrity_algorithms =  ["SHA1","SHA2-256","SHA2-384","SHA2-512"]
  tunnel2_phase2_encryption_algorithms = ["AES256"]
  tunnel2_phase2_dh_group_numbers = ["2","14","19","20","24"]
  tunnel2_ike_versions = ["ikev1","ikev2"]
  tunnel2_dpd_timeout_action = "restart"
  tunnel2_startup_action = "start"

  static_routes_only  = true
  tags = {
    Name = var.vpn_connection_name[0]
  }
}

resource "aws_vpn_connection_route" "default" {
  count = length(var.vpn_route_default)
  destination_cidr_block = var.vpn_route_default[count.index]
  vpn_connection_id      = aws_vpn_connection.default.id
}

### KLM VPN
resource "aws_vpn_connection" "klm" {
  vpn_gateway_id      = aws_vpn_gateway.default.id
  customer_gateway_id = aws_customer_gateway.default["KLM"].id
  type                = "ipsec.1"
  tunnel1_phase1_dh_group_numbers = ["20"]
  tunnel1_phase1_integrity_algorithms =  ["SHA2-384"]
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase2_integrity_algorithms =  ["SHA2-384"]
  tunnel1_phase2_encryption_algorithms = ["AES256"]
  tunnel1_phase2_dh_group_numbers = ["20"]
  tunnel1_ike_versions = ["ikev2"]
  tunnel1_dpd_timeout_action = "restart"
  tunnel1_startup_action = "start"
  
  tunnel2_phase1_dh_group_numbers = ["20"]
  tunnel2_phase1_integrity_algorithms =  ["SHA2-384"]
  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase2_integrity_algorithms =  ["SHA2-384"]
  tunnel2_phase2_encryption_algorithms = ["AES256"]
  tunnel2_phase2_dh_group_numbers = ["20"]
  tunnel2_ike_versions = ["ikev2"]
  tunnel2_dpd_timeout_action = "restart"
  tunnel2_startup_action = "start"

  static_routes_only  = true
  tags = {
    Name = var.vpn_connection_name[1]
  }
}

resource "aws_vpn_connection_route" "klm" {
  count = length(var.vpn_route_klm)
  destination_cidr_block = var.vpn_route_klm[count.index]
  vpn_connection_id      = aws_vpn_connection.klm.id
}

### For NAT-GW
resource "aws_eip" "nat" {
  for_each = var.private_cidr
  vpc   = true
}

### NAT GATEWAY
resource "aws_nat_gateway" "default" {
  for_each = var.private_cidr
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  depends_on = [
    aws_eip.nat,
    aws_subnet.public,
  ]
}

### INTERNET GATEWAY
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

### ROUTE TABLES
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  
  route {
    cidr_block = "10.160.160.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.claranet.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = {
    Name = "Public"
  }
  propagating_vgws = [aws_vpn_gateway.default.id]
}

resource "aws_route_table" "private" {
  for_each = aws_nat_gateway.default
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "10.160.160.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.claranet.id
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }
  tags = {
    Name = "Private"
  }
  propagating_vgws = [aws_vpn_gateway.default.id]
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.value.availability_zone].id
}



resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.default.id
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "s3-private" {
  for_each = aws_subnet.private
  route_table_id = aws_route_table.private[each.value.availability_zone].id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}