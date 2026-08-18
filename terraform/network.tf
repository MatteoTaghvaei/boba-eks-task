resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${local.DEFAULT_NAME}-vpc"
  }
}

#PUBLIC SUBNETS 
resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.DEFAULT_NAME}-subnet-${each.key}"
    "kubernetes.io/role/elb" = "1"
  }
}


resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${local.DEFAULT_NAME}-igw"
  }
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${local.DEFAULT_NAME}-public-rt"
  }
}


resource "aws_route_table_association" "public_rt_association" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}


#PRIVATE SUBNETS
resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${local.DEFAULT_NAME}-subnet-${each.key}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}


resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${local.DEFAULT_NAME}-nat-eip"
  }
}


resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets["public-a"].id

  tags = {
    Name = "${local.DEFAULT_NAME}-nat-gw"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${local.DEFAULT_NAME}-private-rt"
  }
}


resource "aws_route_table_association" "private_rt_association" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}