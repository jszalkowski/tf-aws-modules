variable "account_name" {}

variable "ami_id" {}

variable "aws_keypair" {}

variable "aws_region" {}

variable "ebs_root_size" {
  default = 50
}

variable "instance_name" {}

variable "instance_profile" {}

variable "instance_type" {}

variable "lvm_opt_size" {
  default = 20
}

variable "lvm_var_size" {
  default = 20
}

variable "lvm_varlog_size" {
  default = 20
}

variable "lvm_varlogaudit_size" {
  default = 5
}

variable "lvm_home_size" {
  default = 10
}

variable "lvm_tmp_size" {
  default = 5
}

variable "snapshots" {
  default = "no"
}

variable "subnet" {}

variable "termination_protection" {
  default = "false"
}

variable "userdata" {}

variable "vpc_security_group_ids" {
  type = "list"
}

resource "aws_instance" "ec2_instance" {
  ami                     = "${var.ami_id}"
  disable_api_termination = "${var.termination_protection}"

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdb"
    volume_size           = "${(var.lvm_opt_size) + (var.lvm_var_size) + (var.lvm_varlog_size) + (var.lvm_varlogaudit_size) + (var.lvm_home_size) + (var.lvm_tmp_size) + 20}"
    volume_type           = "gp2"
  }

  iam_instance_profile = "${var.instance_profile}"
  instance_type        = "${var.instance_type}"

  lifecycle {
    "ignore_changes" = ["ami"]
  }

  key_name = "${var.aws_keypair}"

  root_block_device {
    delete_on_termination = true
    volume_size           = "${var.ebs_root_size}"
    volume_type           = "gp2"
  }

  subnet_id = "${var.subnet}"

  tags {
    Name      = "${var.instance_name}"
    Snapshots = "${var.snapshots}"
  }

  user_data = "${var.userdata}"

  volume_tags {
    Name = "${var.instance_name}"
  }

  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
}
