# Security Group (sg)

resource "aws_security_group" "sg" {
  name        = "Custom SG"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"
 
# inbound traffic 
  
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
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = "true"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
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
  tags { Name = "${var.sg_tags}" }
}

