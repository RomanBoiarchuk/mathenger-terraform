resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.app_name}-vpc"
  }
}
#########
# subnets
#########
resource "aws_subnet" "db-subnet-1" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.vpc.id
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "${var.app_name}-db-subnet 1"
  }
}

resource "aws_subnet" "db-subnet-2" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.vpc.id
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "${var.app_name}-db-subnet 2"
  }
}
#################
#internet gateway
#################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.app_name} Internet Gateway"
  }
}
############
#Route Table
############
resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.app_name} Route Table"
  }
}
#########################
#Route table associations
#########################
resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.route-table.id
}

resource "aws_route_table_association" "route-table-db-subnet-1" {
  route_table_id = aws_route_table.route-table.id
  subnet_id = aws_subnet.db-subnet-1.id
}

resource "aws_route_table_association" "route-table-db-subnet-2" {
  route_table_id = aws_route_table.route-table.id
  subnet_id = aws_subnet.db-subnet-2.id
}
