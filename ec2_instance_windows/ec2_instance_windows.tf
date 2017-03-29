variable "account_name" {}

variable "ami_id" {}

variable "aws_keypair" {}

variable "aws_region" {}

variable "instance_name" {}

variable "instance_profile" {}

variable "instance_type" {}

variable "snapshots" {
  default = "no"
}

variable "subnet" {}

variable "termination_protection" {
  default = "false"
}

variable "vpc_security_group_ids" {
  type = "list"
}

resource "aws_instance" "ec2_instance" {
  ami                     = "${var.ami_id}"
  disable_api_termination = "${var.termination_protection}"
  key_name                = "${var.aws_keypair}"
  iam_instance_profile    = "${var.instance_profile}"
  instance_type           = "${var.instance_type}"
  subnet_id               = "${var.subnet}"

  tags {
    Name      = "${var.instance_name}"
    Snapshots = "${var.snapshots}"
  }

  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
}
