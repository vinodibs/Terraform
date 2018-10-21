
output "ami" {
  value = "${var.ami}" 
}

output "instance_type" {
  value = "${var.instance_type}" 
}

output "key_name" {
  value = "${var.key_name}" 
}

output "associate_public_ip_address" {
  value = "${var.associate_public_ip_address}" 
}

output "ec2_count" {
  value = "${var.ec2_count}"
}

output "root_volume_size" {
  value = "${var.root_volume_size}" 
}

output "ec2_tags" {
  value = "${var.ec2_tags}" 
}


