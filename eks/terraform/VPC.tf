resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_name
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
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = {
    Name = "Public"
  }
}

resource "aws_route_table" "private" {
  for_each = aws_nat_gateway.default
  vpc_id = aws_vpc.default.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }
  tags = {
    Name = "Private"
  }

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