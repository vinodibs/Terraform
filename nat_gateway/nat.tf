# Elastic IP 
resource "aws_eip" "nat_eip" {
    vpc = true
   tags { Name = "nat_eip" }
}

# Allocate EIP to Nat Gateway 
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "Public-Subnet-0" 
    tags { Name = "Nat_Gateway" }
}
