variable "region" {
  description = "Define Here region"
  default     = "ap-southeast-1"
}

variable "vpc_tags" {
  description = "VPC Tags"
  default     = "test-vpc"
}

variable "sg_tags" {
  description = "SG tags Name"
  default     = "Custom SG"
}

variable "ami" {
  description = "ami"
  default     = "ami-0eb1f21bbd66347fe"
}

variable "instance_type" {
  description = "instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "key_name"
  default     = "test-key"
}

variable "associate_public_ip_address" {
  description = "associate_public_ip_address"
  default     = false
}

variable "ec2_count" {
  description = "ec2_count"
  default     = "1"
}

variable "root_volume_size" {
  description = "root_volume_size"
  default     = "30"
}

variable "ec2_tags" {
  description = "ec2_tags"
  default     = "test-ec2"
}




