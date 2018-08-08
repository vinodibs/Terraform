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

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "Allow all traffic"
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


# Internet Gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "Internet Gateway"
  }
}

# Elastic IP 
resource "aws_eip" "eip" {
    vpc = true
   tags {
    Name = "EIP"
  }
}

# Elastic IP 
resource "aws_eip" "nat_eip" {
    vpc = true
   tags {
    Name = "Nat Gateway Elastic Ip"
  }
}

# Allocate EIP to Ec2 Instance
resource "aws_eip_association" "eip_assoc" {
 instance_id   = "${aws_instance.Public_Ec2.id}"
  allocation_id = "${aws_eip.eip.id}"
}


# Allocate EIP to Nat Gateway 
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.Public_Subnet.id}"
  
    tags {
    Name = "Allocate EIP to Nat Gateway"
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

# Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "deployer"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCehKGLhFOiv/hCNWjl+fkm5SPiobKw2U7vLVplK5GpKRhk2gnVib6+Wmk8fNHDvsN5YMDQDx0WAGJ+h0jqQ4hVEVlGrnOAr3cYnkQIYUGKe1WMDlmsiJO0VpOM3rV6bia0z4BM84Px9El2bDFPkv5eRoL1NlYTmYLcsYmZJjbRGw0Qnp59phEGfkUbBVZ+uREE+FzzM1Alk+RS9xh3AuB4IPtkUYQbFLZ0c+fxxzENGwiS9yaD/CUprj5L9xqXS0rXkCabTXetn+OyXy/sMfwjtAPS/mh8eCRjYiyqMt783facgc6SaFZGr4AOruKGG2o9Y/FoqJoTuM5GSzf9vXLp vmuser@Ubuntu-16"
}

# Public Ec2-Instance
resource "aws_instance" "Public_Ec2" {
  ami                                  = "ami-188fba77" # Ubuntu 16.04
  instance_type                        = "t2.micro"
  instance_initiated_shutdown_behavior = "stop"
  key_name                             = "${aws_key_pair.key_pair.id}"
  disable_api_termination              = "true"
  subnet_id                            = "${aws_subnet.Public_Subnet.id}"
  associate_public_ip_address          = "true"
  vpc_security_group_ids               = ["${aws_security_group.sg.id}"]
  ebs_optimized                        = false
  monitoring                           = true
  count                                = "1"

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
    Name = "Public-Ec2-Ubuntu-16.04"
  }
}

# Private Ec2-Instance
resource "aws_instance" "Private_Ec2" {
  ami                                  = "ami-188fba77" # Ubuntu 16.04
  instance_type                        = "t2.micro"
  instance_initiated_shutdown_behavior = "stop"
  key_name                             = "${aws_key_pair.key_pair.id}"
  disable_api_termination              = "true"
  subnet_id                            = "${aws_subnet.Private_Subnet.id}"
  associate_public_ip_address          = "true"
  vpc_security_group_ids               = ["${aws_security_group.sg.id}"]
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
    Name = "Priate-Ec2-Ubuntu-16.04"
  }
}

# Mysql db
resource "aws_db_instance" "db_instance" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.small"
  name                 = "mydb"
  username             = "mydbinstance"
  password             = "mydbinstance"
  parameter_group_name = "default.mysql5.7"
  identifier           = "mydb"
  storage_encrypted    = false
  publicly_accessible  = true
  apply_immediately    = false
  multi_az             = false
  port                 = "3306"
  maintenance_window   = "Mon:00:00-Mon:03:00"
  backup_window        = "03:00-06:00"
  backup_retention_period = 0
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.db_subnet_group.id}" 
}
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "main_subnet_group"
  description = "Our main group of subnets"
  subnet_ids  = ["${aws_subnet.Public_Subnet.id}", "${aws_subnet.Private_Subnet.id}"]
}

