provider "aws" {
  region             = "${var.region}"
}

module "vpc" {
  source             =  "./vpc"
  vpc_tags           =  "${var.vpc_tags}"
}

module "security_groups" {
  source             =  "./sg"
  vpc_id             =  "${module.vpc.id}"
  sg_tags            =  "${var.sg_tags}"
}

module "public" {
  source             =  "./public"
  vpc_id             =  "${module.vpc.id}"
}

module "private" {
  source             =  "./private"
  vpc_id             =  "${module.vpc.id}"
  subnet_id          =  "${module.public.public-sub0}"
}

module "ec2_instance" {
  source             = "./ec2_instance"
  vpc_id             = "${module.vpc.id}"
  subnet_id          =  "${module.public.public-sub0}"
#  subnet_id          = "${module.private.private-sub0}"
  security_groups    = ["${module.security_groups.id}"]
  ami                = "${var.ami}"
  instance_type      = "${var.instance_type}"
  key_name           = "${var.key_name}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  ec2_count          = "${var.ec2_count}"
  root_volume_size   = "${var.root_volume_size}"
  ec2_tags           = "${var.ec2_tags}"

}


