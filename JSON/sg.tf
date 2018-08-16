# Provider AWS
provider "aws" {
    region = "${var.region}"
}

# VPC  
resource "aws_vpc" "vpc"{
cidr_block  = "${var.vpc_cidr}"
instance_tenancy = "default"
enable_dns_support = "true"
enable_dns_hostnames = "true"
tags {
    Name = "VPC"
  }
}

# Public Subnet 
resource "aws_subnet" "Public_Subnet" { 
 # count      = "${length(var.azs)}"
  count      = "${length(data.aws_availability_zones.azs.names)}"
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${element(var.public_cidr_block,count.index)}"
  tags {
    Name = "Public_Subnet-${count.index+1}"
  }
}

# Private Subnet 
resource "aws_subnet" "Private_Subnet" {
 # count      = "${length(var.azs)}"
  count      = "${length(data.aws_availability_zones.azs.names)}"
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${element(var.private_cidr_block,count.index)}"
  tags {
  Name = "Private_Subnet-${count.index+1}"
  }
}

# Internet Gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "Internet Gateway (igw)"
  }
}

# Public Route Table for Internet Gateway
resource "aws_route_table" "Public_Route" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags {
    Name = "Public Route for IGW"
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

# Allocate EIP to Nat Gateway 
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${var.public_subnet}"
    tags {
    Name = "Allocate EIP to Nat Gateway"
  }
} 

# Elastic IP 
resource "aws_eip" "nat_eip" {
    vpc = true
   tags {
    Name = "Nat Gateway Elastic Ip"
  }
}

data "aws_subnet" "Public_Subnet" {
  filter {
    name = "tag:Name"
    values = ["Private_Subnet-${count.index+1}"]
  }
}