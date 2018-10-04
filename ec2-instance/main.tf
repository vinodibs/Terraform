provider "aws" {
  region = "${var.region}"
}

# Public Ec2-Instance
resource "aws_instance" "Public_Ec2" {
  ami                                  = "${var.ami}"  # Ubuntu 16.04 "ami-188fba77"
  instance_type                        = "${var.instance_type}"
  instance_initiated_shutdown_behavior = "stop"
  key_name                             = "${var.key_name}"
  disable_api_termination              = "${var.disable_api_termination}"
  subnet_id                            = "${var.subnet_id}"
  associate_public_ip_address          = "${var.associate_public_ip_address}"
  vpc_security_group_ids               = ["${var.vpc_security_group_ids}"]
  ebs_optimized                        = "false"
  monitoring                           = "true"
  count                                = "${var.count}"
 
# Root EBS Volume Size
root_block_device {
volume_type 	= "gp2"
volume_size		= "${var.volume_size}"
}

  tags {
    Name = "Public-Ec2-Ubuntu-16.04"
  }
  
}
