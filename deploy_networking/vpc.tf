# Internet VPC
resource "aws_vpc" "${var.ENV}-main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "${var.ENV}-main"
  }
}

# Subnets
resource "aws_subnet" "${var.ENV}-public-1" {
  vpc_id                  = aws_vpc.${var.ENV}-main.id
  cidr_block              = "10.70.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.AWS_REGION}a"

  tags = {
    Name = "${var.ENV}-public-1"
  }
}

resource "aws_subnet" "${var.ENV}-public-2" {
  vpc_id                  = aws_vpc.${var.ENV}-main.id
  cidr_block              = "10.70.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.AWS_REGION}b"

  tags = {
    Name = "${var.ENV}-public-2"
  }
}

resource "aws_subnet" "${var.ENV}-public-3" {
  vpc_id                  = aws_vpc.${var.ENV}-main.id
  cidr_block              = "10.70.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.AWS_REGION}c"

  tags = {
    Name = "${var.ENV}-public-3"
  }
}

resource "aws_subnet" "${var.ENV}-private-1" {
  vpc_id                  = aws_vpc.${var.ENV}-main.id
  cidr_block              = "10.70.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.AWS_REGION}a"

  tags = {
    Name = "${var.ENV}-private-1"
  }
}

resource "aws_subnet" "${var.ENV}-private-2" {
  vpc_id                  = aws_vpc.${var.ENV}-main.id
  cidr_block              = "10.70.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.AWS_REGION}b"

  tags = {
    Name = "${var.ENV}-private-2"
  }
}

resource "aws_subnet" "${var.ENV}-private-3" {
  vpc_id                  = aws_vpc.${var.ENV}-main.id
  cidr_block              = "10.70.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.AWS_REGION}c"

  tags = {
    Name = "${var.ENV}-private-3"
  }
}

# Internet GW
resource "aws_internet_gateway" "${var.ENV}-main-gw" {
  vpc_id = aws_vpc.${var.ENV}-main.id

  tags = {
    Name = "${var.ENV}-main-gw"
  }
}

# route tables
resource "aws_route_table" "${var.ENV}-public" {
  vpc_id = aws_vpc.${var.ENV}-main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.${var.ENV}-main-gw.id
  }

  tags = {
    Name = "${var.ENV}-public-1"
  }
}

# route associations public
resource "aws_route_table_association" "${var.ENV}-public-1-a" {
  subnet_id      = aws_subnet.${var.ENV}-public-1.id
  route_table_id = aws_route_table.${var.ENV}-public.id
}

resource "aws_route_table_association" "${var.ENV}-public-2-a" {
  subnet_id      = aws_subnet.${var.ENV}-public-2.id
  route_table_id = aws_route_table.${var.ENV}-public.id
}

resource "aws_route_table_association" "${var.ENV}-main-public-3-a" {
  subnet_id      = aws_subnet.${var.ENV}-public-3.id
  route_table_id = aws_route_table.${var.ENV}-public.id
}

resource "aws_route_table" "${var.ENV}-private" {
  vpc_id = aws_vpc.${var.ENV}-main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "${var.ENV}-private-1"
  }
}

# route associations private
resource "aws_route_table_association" "${var.ENV}-private-1-a" {
  subnet_id      = aws_subnet.${var.ENV}-private-1.id
  route_table_id = aws_route_table.${var.ENV}-private.id
}

resource "aws_route_table_association" "${var.ENV}-private-2-a" {
  subnet_id      = aws_subnet.${var.ENV}-private-2.id
  route_table_id = aws_route_table.${var.ENV}-private.id
}

resource "aws_route_table_association" "${var.ENV}-private-3-a" {
  subnet_id      = aws_subnet.${var.ENV}-private-3.id
  route_table_id = aws_route_table.${var.ENV}-private.id
}

# nat gw
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.${var.ENV}-public-1.id
  depends_on    = [aws_internet_gateway.${var.ENV}-main-gw]
}
