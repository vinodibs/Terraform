# Aws Region 
variable "region" {
     default = "ap-northeast-2"
     description = "The AWS Region"
}

# VPC Cidr Block 
variable "vpc_cidr" {
    default = "192.168.0.0/16"
}

#  Public Subnet  Cidr Block
variable "public_cidr_block" {
    type = "list"
    default = ["192.168.1.0/24","192.168.2.0/24","192.168.3.0/24","192.168.4.0/24","192.168.5.0/24"]
}

# Private Subnet  Cidr Block
variable "private_cidr_block" {
    type = "list"
    default = ["192.168.6.0/24","192.168.7.0/24","192.168.8.0/24","192.168.9.0/24","192.168.10.0/24"]
}

#AZsyes
#variable "azs" {
#    type = "list"
#    default = ["ap-northeast-2a","ap-northeast-2c"]
#}

# Sunet-id Nat Gateway
variable "public_subnet" {
    default = "subnet-0bc0e4be7580e6ab6"
}

# Declare the data source
data "aws_availability_zones" "azs"{}

























