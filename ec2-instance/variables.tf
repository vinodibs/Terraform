variable "region" {
  description = "Provide here region name"
  type        = "string"
  default     = ""
}

variable "ami" {
  description = "ami"
  type        = "string"
  default     = ""
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

variable "subnet_id" {
  description = "subnet_id"
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "vpc_security_group_ids"
  type        = "string"
  default     = ""
}

variable "count" {
  description = "count"
  default	  = "1"
}

variable "volume_tags" {
  description = "volume_tags"
  default     = "vinod"
}

variable "volume_size" {
  description = "volume_size"
  type        = "string"
  default     = ""
}
