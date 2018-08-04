provider "aws" {
  region = "ap-south-1"
}

# VPC Creation with tags 
resource "aws_vpc" "Audiolody"{
cidr_block  = "10.0.0.0/24"
instance_tenancy = "default"
enable_dns_support = "true"
enable_dns_hostnames = "true"

tags {
    Name = "Audiology-Vpc"
    Location = "USA"
}

}

# Public Subnet for Audiology
resource "aws_subnet" "Public_Subnet" { 
  vpc_id     = "${aws_vpc.Audiolody.id}"
  cidr_block = "10.0.0.0/26"
  availability_zone = "ap-south-1b"
  tags {
    Name = "Public Subnet"
  }
}

# Private Subnet for Audiology
resource "aws_subnet" "Private_Subnet" {
  vpc_id     = "${aws_vpc.Audiolody.id}"
  cidr_block = "10.0.0.64/26"
  availability_zone = "ap-south-1a"
  tags {
    Name = "Private Subnet"
  }
}

# Private Route table Association
resource "aws_main_route_table_association" "Private_Association" {
  vpc_id         = "${aws_vpc.Audiolody.id}"
  route_table_id = "${aws_route_table.Private_Route.id}"
}

# Public Route table Association
resource "aws_route_table_association" "Public_Association" {
  subnet_id      = "${aws_subnet.Public_Subnet.id}"
  route_table_id = "${aws_route_table.Public_Route.id}"
  
}

# Public Route Table for Audiology
resource "aws_route_table" "Public_Route" {
  vpc_id = "${aws_vpc.Audiolody.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Audiology_igw.id}"
  }

  tags {
    Name = "Public Route Table"
  }
}

# Private Route Table for Audiology
resource "aws_route_table" "Private_Route" {
  vpc_id = "${aws_vpc.Audiolody.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags {
    Name = "Private Route Table"
  }
}

# Internet Gateway for Audiology
resource "aws_internet_gateway" "Audiology_igw" {
  vpc_id = "${aws_vpc.Audiolody.id}"
  tags {
    Name = "Audiology_igw"
  }
}

# DHCP Options Set Create
resource "aws_vpc_dhcp_options" "Audiology_Dhcp" {
  domain_name          = "audiologydesign.local"
  domain_name_servers  = ["127.0.0.1"]
  ntp_servers          = ["127.0.0.1"]
  netbios_name_servers = ["127.0.0.1"]
  netbios_node_type    = 2

  tags {
    Name = "Audiology_Dhcp"
  }
}

# Elastic IP 
resource "aws_eip" "Audiology-EIP" {
    vpc = true
   tags {
    Name = "Audiology-EIP"
  }
}

# Elastic IP 
resource "aws_eip" "Nat_EIP" {
    vpc = true
   tags {
    Name = "Nat-EIP"
  }
}

# Allocate EIP to Ec2 Instance
resource "aws_eip_association" "eip_assoc" {
 instance_id   = "${aws_instance.Public_Ec2.id}"
  allocation_id = "${aws_eip.Audiology-EIP.id}"
}

# Allocate EIP to Nat Gateway 
resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.Nat_EIP.id}"
  subnet_id     = "${aws_subnet.Public_Subnet.id}"

  tags {
    Name = "NAT Gateway"
  }
}

# Security Group
resource "aws_security_group" "Audiology-SG" {
  name        = "Allow_All"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.Audiolody.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "Audiology-SG"
  }
}

# Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCehKGLhFOiv/hCNWjl+fkm5SPiobKw2U7vLVplK5GpKRhk2gnVib6+Wmk8fNHDvsN5YMDQDx0WAGJ+h0jqQ4hVEVlGrnOAr3cYnkQIYUGKe1WMDlmsiJO0VpOM3rV6bia0z4BM84Px9El2bDFPkv5eRoL1NlYTmYLcsYmZJjbRGw0Qnp59phEGfkUbBVZ+uREE+FzzM1Alk+RS9xh3AuB4IPtkUYQbFLZ0c+fxxzENGwiS9yaD/CUprj5L9xqXS0rXkCabTXetn+OyXy/sMfwjtAPS/mh8eCRjYiyqMt783facgc6SaFZGr4AOruKGG2o9Y/FoqJoTuM5GSzf9vXLp vmuser@Ubuntu-16"
}

# Public Ec2-Instance
resource "aws_instance" "Public_Ec2" {
  ami                                  = "ami-188fba77" # Ubuntu 16.04
  instance_type                        = "t2.micro"
  instance_initiated_shutdown_behavior = "stop"
  key_name                             = "${aws_key_pair.deployer.id}"
  disable_api_termination              = "true"
  subnet_id                            = "${aws_subnet.Public_Subnet.id}"
  associate_public_ip_address          = "true"
  vpc_security_group_ids               = ["${aws_security_group.Audiology-SG.id}"]
  ebs_optimized                        = false
  monitoring                           = true
  

# Set Root EBS Volume Size
root_block_device {
volume_type = "gp2"
volume_size = "60"
delete_on_termination = "true"
}

# Add & Attached EBS Volume 
ebs_block_device {
device_name = "/dev/sdb"
volume_size = "80"
volume_type = "gp2"
delete_on_termination = false
#snapshot_id = "snap-x123x123"
}
  tags {
    Name = "Public-Ubuntu-16.04"
  }
}
# Private Ec2-Instance
resource "aws_instance" "Private_Ec2" {
  ami                                  = "ami-188fba77" # Ubuntu 16.04
  instance_type                        = "t2.micro"  
  instance_initiated_shutdown_behavior = "stop"
  key_name                             = "${aws_key_pair.deployer.id}"
  disable_api_termination              = "true"
  subnet_id                            = "${aws_subnet.Private_Subnet.id}"
  associate_public_ip_address          = "true"
  vpc_security_group_ids               = ["${aws_security_group.Audiology-SG.id}"]
  ebs_optimized                        = false
  monitoring                           = true
  count                                = "1"
# Set Root EBS Volume Size
root_block_device {
volume_type = "gp2"
volume_size = "60"
delete_on_termination = "true"
}
  tags {
    Name = "Private-Ubuntu-16.04"
  }
}