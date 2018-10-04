variable "region" {
  description = "Provide here region name"
  default     = "us-east-2"
}

variable "ami" {
  description = "ami"
  default     = "ami-0782e9ee97725263d"
}

variable "instance_type" {
  description = "Type of instance"
  default     = "t2.micro"
}

variable "key_name" {
  description = "key_name"
  default	  = "tt"
}

variable "disable_api_termination" {
  description = "disable_api_termination"
  default     = "true"
}

variable "associate_public_ip_address" {
  description = "associate_public_ip_address"
  default     = "true"
}

variable "vpc_security_group_ids" {
  description = "vpc_security_group_ids"
  default     = "default"
}

variable "count" {
  description = "count"
  default	  = "1"
}


variable "monitoringe" {
  description = "monitoring"
  default     = "false"
}

variable "volume_size" {
  description = "volume_size"
  default     = "60"
}
