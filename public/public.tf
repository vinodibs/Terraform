# Internet gateway (igw)
resource "aws_internet_gateway" "igw" {
  vpc_id      = "${var.vpc_id}"
  tags { Name = "Public-igw" }
}

# Public Route Table for Internet Gateway
resource "aws_route_table" "public_route" {
  vpc_id      = "${var.vpc_id}"
  route { cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}" }
  tags { Name = "Public Route" }
}

# Declare the data source
data "aws_availability_zones" "available" {}

resource "aws_subnet" "public-sub0" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  vpc_id      = "${var.vpc_id}"
  cidr_block = "10.0.1.0/24"  
  tags { Name = "Public-Subnet-0" }
}

# Public Route table Association
resource "aws_route_table_association" "public_rt0" {
  subnet_id      = "${element(aws_subnet.public-sub0.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public_route.*.id, count.index)}"
}

# Public Subnet
resource "aws_subnet" "public-sub1" {
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  vpc_id      = "${var.vpc_id}"
  cidr_block = "10.0.2.0/24"  
  tags { Name = "Public-Subnet-1" }
}

# Public Route table Association
resource "aws_route_table_association" "public_rt1" {
  subnet_id      = "${element(aws_subnet.public-sub1.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public_route.*.id, count.index)}"
}

# Public Subnet
resource "aws_subnet" "public-sub2" {
  availability_zone = "${data.aws_availability_zones.available.names[2]}"
  vpc_id      = "${var.vpc_id}"
  cidr_block = "10.0.3.0/24" 
  tags { Name = "Public-Subnet-2" }
}

# Public Route table Association
resource "aws_route_table_association" "public_rt2" {
  subnet_id      = "${element(aws_subnet.public-sub2.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public_route.*.id, count.index)}"
}


