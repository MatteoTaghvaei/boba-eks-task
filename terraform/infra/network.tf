# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${local.DEFAULT_NAME}-vpc"
  }
}

# Public subnets 
resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${local.DEFAULT_NAME}-subnet-${each.key}"
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

# Private subnets
resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name                              = "${local.DEFAULT_NAME}-subnet-${each.key}"
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

# EKS security groups
resource "aws_security_group" "eks_control_plane_sg" {
  name        = "${local.DEFAULT_NAME}-eks-control-plane-sg"
  description = "EKS control plane security group"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "${local.DEFAULT_NAME}-eks-control-plane-sg"
  }
}

resource "aws_security_group" "eks_nodes_sg" {
  name        = "${local.DEFAULT_NAME}-eks-nodes-sg"
  description = "EKS worker nodes security group"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "${local.DEFAULT_NAME}-eks-nodes-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_ingress_rule" {
  for_each = local.EKS_INGRESS_RULES

  security_group_id            = each.value.security_group_id
  referenced_security_group_id = each.value.source_sg_id

  from_port = try(each.value.from_port, null)
  to_port   = try(each.value.to_port, null)
  ip_protocol = each.value.protocol
}

resource "aws_vpc_security_group_egress_rule" "eks_egress_rules" {
  for_each = local.EKS_EGRESS_RULES

  security_group_id = each.value.security_group_id
  cidr_ipv4         = each.value.cidr
  ip_protocol       = each.value.protocol
}

# RDS security group
resource "aws_security_group" "mysql_sg" {
  name        = "${local.DEFAULT_NAME}-mysql-sg"
  description = "MySQL security group"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }

  tags = {
    Name = "${local.DEFAULT_NAME}-mysql-sg"
  }
}