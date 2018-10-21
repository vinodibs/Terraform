# Public Ec2-Instance
resource "aws_instance" "public_ec2" {
  ami                                  = "${var.ami}"
  instance_type                        = "${var.instance_type}"
  instance_initiated_shutdown_behavior = "stop"
  key_name                             = "${var.key_name}"
  disable_api_termination              = "true"
  subnet_id                            = "${var.subnet_id}"
  associate_public_ip_address          = "${var.associate_public_ip_address}"
  security_groups                      = ["${var.security_groups}"] 
  ebs_optimized                        = false
  monitoring                           = false
  user_data                            = "${file("./user_data/wp.sh")}"
  count                                = "${var.ec2_count}"

# Set Root EBS Volume Size
root_block_device {
  volume_type                          = "gp2"
  volume_size                          = "${var.root_volume_size}"
  delete_on_termination                = "true" }
  tags { Name                          = "${var.ec2_tags}" }
}


# EIP for Ec2 Instance
resource "aws_eip" "eip" {
  vpc                                 = true
  tags { Name                         = "ec2_eip" }
}

# EIP association 
resource "aws_eip_association" "eip_assoc" {
  instance_id                         = "${aws_instance.public_ec2.id}"
  allocation_id                       = "${aws_eip.eip.id}" }
