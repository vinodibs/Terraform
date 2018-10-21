# NAT EIP  
resource "aws_eip" "nat_eip" {
  vpc = true
  tags { Name = "Nat_EIP" }
}

# Allocate EIP to Nat Gateway 
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id         = "${var.subnet_id}"
  tags { Name = "Nat_Gateway" }
}

# Private Route Table for Nat Gateways
resource "aws_route_table" "private_route" {
  vpc_id      = "${var.vpc_id}"
  route { cidr_block     = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.nat_gw.id}" }
  tags { Name = "Private Route" }
}

# Declare the data source
data "aws_availability_zones" "available" {}

resource "aws_subnet" "private-sub0" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  vpc_id      = "${var.vpc_id}"
  cidr_block = "10.0.100.0/24"  
  tags { Name = "Private-Subnet-0" }
}

# private Route table Association
resource "aws_route_table_association" "private_rt0" {
  subnet_id      = "${element(aws_subnet.private-sub0.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_route.*.id, count.index)}"
}

#private Subnet
resource "aws_subnet" "private-sub1" {
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  vpc_id      = "${var.vpc_id}"
  cidr_block = "10.0.101.0/24"  
  tags { Name = "Private-Subnet-1" }
}

# private Route table Association
resource "aws_route_table_association" "private_rt1" {
  subnet_id      = "${element(aws_subnet.private-sub1.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_route.*.id, count.index)}"
}

#private Subnet
resource "aws_subnet" "private-sub2" {
  availability_zone = "${data.aws_availability_zones.available.names[2]}"
  vpc_id      = "${var.vpc_id}"
  cidr_block = "10.0.102.0/24" 
  tags { Name = "Private-Subnet-2" }
}

# private Route table Association
resource "aws_route_table_association" "private_rt2" {
  subnet_id      = "${element(aws_subnet.private-sub2.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_route.*.id, count.index)}"
}

