output "name" {
  value = "${var.vpc_tags}"
}

output "id" {
  value = "${aws_vpc.vpc.id}"
}


