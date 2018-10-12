provider "aws" {
  region = "ca-central-1"
}

# VPC  
resource "aws_vpc" "vpc"{
cidr_block  = "10.0.0.0/16"
instance_tenancy = "default"
enable_dns_support = "true"
enable_dns_hostnames = "true"

tags { Name = "vpc" }
} 

# Declare the data source
data "aws_availability_zones" "available" {}

#Public Subnet
resource "aws_subnet" "public-sub0" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.1.0/24"  
  tags { Name = "Public-Subnet-0" }
}

#Public Subnet
resource "aws_subnet" "public-sub1" {
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.2.0/24"  
  tags { Name = "Public-Subnet-1" }
}


# Public Route Table for Internet Gateway
resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags { Name = "Public Route" }
} 

# Public Route table Association
resource "aws_route_table_association" "public_rt0" {
  subnet_id      = "${element(aws_subnet.public-sub0.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public_route.*.id, count.index)}"
  
}


# Public Route table Association
resource "aws_route_table_association" "public_rt1" {
  subnet_id      = "${element(aws_subnet.public-sub1.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public_route.*.id, count.index)}"
  
}

# Public Route table Association
resource "aws_route_table_association" "public_rt2" {
  subnet_id      = "${element(aws_subnet.public-sub2.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public_route.*.id, count.index)}"
  
}

# Internet Gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags { Name = "Internet_Gateway" }
}

#Private Subnet
resource "aws_subnet" "private-sub0" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.100.0/24"  
  tags { Name = "Private-Subnet-0" }
}

#Private Subnet
resource "aws_subnet" "private-sub1" {
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.101.0/24" 
  tags { Name = "Private-Subnet-1" } 
}

#Private Subnet
resource "aws_subnet" "private-sub2" {
  availability_zone = "${data.aws_availability_zones.available.names[2]}"
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.102.0/24" 
  tags { Name = "Private-Subnet-2" }
}

# Private Route Table Nat gateway
resource "aws_route_table" "private_route" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }
tags { Name = "Private Route" }
}


# Private Route table Association
resource "aws_route_table_association" "private_rt0" {
  subnet_id      = "${element(aws_subnet.private-sub0.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_route.*.id, count.index)}"
}


# Private Route table Association
resource "aws_route_table_association" "private_rt1" {
  subnet_id      = "${element(aws_subnet.private-sub1.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_route.*.id, count.index)}"
  
}

# Private Route table Association
resource "aws_route_table_association" "private_rt2" {
  subnet_id      = "${element(aws_subnet.private-sub2.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_route.*.id, count.index)}"
  
}

# Elastic IP 
resource "aws_eip" "nat_eip" {
    vpc = true
   tags { Name = "Nat_EIP" }
}

# Allocate EIP to Nat Gateway 
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public-sub0.id}"
  tags { Name = "Nat_Gateway" }
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
    description = "SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "true"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = "true"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
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

