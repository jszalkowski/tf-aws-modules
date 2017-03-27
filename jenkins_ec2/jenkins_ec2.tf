variable "account_name" {}
variable "ami_id" {}
variable "aws_keypair" {}
variable "aws_region" {}
variable "chef_policy" {}
variable "chef_policy_group" {}
variable "chef_server" {}
variable "chef_server_url" {}
variable "instance_profile" {}

variable "instance_type" {
  default = "t2.medium"
}

variable "lvm_snapshot_id" {}

variable "security_groups" {
  type = "list"
}

variable "subnet" {}
variable "vpc" {}

module "jenkins_ec2" {
  account_name           = "${var.account_name}"
  ami_id                 = "${var.ami_id}"
  aws_keypair            = "${var.aws_keypair}"
  aws_region             = "${var.aws_region}"
  chef_policy            = "${var.chef_policy}"
  chef_policy_group      = "${var.chef_policy_group}"
  chef_server            = "${var.chef_server}"
  chef_server_url        = "${var.chef_server_url}"
  instance_name          = "jenkins"
  instance_profile       = "${var.instance_profile}"
  instance_type          = "${var.instance_type}"
  lvm_snapshot_id        = "${var.lvm_snapshot_id}"
  snapshots              = "yes"
  subnet                 = "${var.subnet}"
  termination_protection = "true"
  vpc_security_group_ids = ["${var.security_groups}"]
  source                 = "github.com/Trility/tf-aws-modules//ec2_instance"
}
