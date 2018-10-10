provider "aws" {
  region = "ap-south-1"
}

# VPC  
resource "aws_vpc" "vpc"{
cidr_block  = "10.0.0.0/16"
instance_tenancy = "default"
enable_dns_support = "true"
enable_dns_hostnames = "true"

tags {
    Name = "VPC"
  }
}

# Public Subnet 
resource "aws_subnet" "Public_Subnet" { 
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-south-1a"
  tags {
    Name = "Public Subnet"
  }
}

# Private Subnet 
resource "aws_subnet" "Private_Subnet" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-south-1b"
  tags {
    Name = "Private Subnet"
  }
}

# Private Route table Association
resource "aws_main_route_table_association" "Private_Association" {
  vpc_id         = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.Private_Route.id}"
}

# Public Route table Association
resource "aws_route_table_association" "Public_Association" {
  subnet_id      = "${aws_subnet.Public_Subnet.id}"
  route_table_id = "${aws_route_table.Public_Route.id}"
}

# Public Route Table for Internet Gateway
resource "aws_route_table" "Public_Route" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags {
    Name = "Public Route Table"
  }
}

# Private Route Table Nat gateway
resource "aws_route_table" "Private_Route" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }
  tags {
    Name = "Private Route Table"
  }
}

# Security Group
resource "aws_security_group" "sg" {
  name        = "Allow_All"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.vpc.id}"

# inbound traffic 
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "inbound traffic for all"
  }
  tags {
    Name = "Allow all inbound traffic"
  }
  
ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = "true"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh"
  }

ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    self        = "true"
    cidr_blocks = ["0.0.0.0/0"]
    description = "RDP"
  }
  
# outbound traffic 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "outbound traffic for all"
  }
  tags {
    Name = "Allow all outbound traffic"
  }
}

# Internet Gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "Internet Gateway"
  }
}

# Nat Gateway EIP
resource "aws_eip" "nat_eip" {
    vpc = true
   tags {
    Name = "Nat Gateway Elastic Ip"
  }
}

# Allocate EIP to Nat Gateway 
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.Public_Subnet.id}"
    tags {
    Name = "Allocate EIP to Nat Gateway"
  }
}

