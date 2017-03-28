variable "account_id" {}
variable "account_name" {}
variable "ami_id" {}
variable "aws_keypair" {}
variable "aws_region" {}
variable "chef_policy" {}
variable "chef_policy_group" {}
variable "chef_server" {}
variable "chef_server_url" {}

variable "instance_type" {
  default = "t2.medium"
}

variable "lvm_snapshot_id" {}

variable "subnet" {}
variable "sg_ssh_id" {}
variable "vpc" {}

module "openvpn_bucket" {
  bucket_logging = "${var.account_name}-logs-s3"
  bucket_name    = "${var.account_name}-openvpn"
  logging_prefix = "${var.account_name}-openvpn/"
  source         = "github.com/Trility/tf-aws-modules//s3_bucket"
}

module "sg_openvpn" {
  group_name        = "openvpn"
  group_description = "openvpn"
  vpc_id            = "${var.vpc}"
  source            = "github.com/Trility/tf-aws-modules//sg"
}

module "sg_1194_udp_ingress" {
  rule_type   = "ingress"
  from_port   = 1194
  to_port     = 1194
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "udp"
  sg_id       = "${module.sg_openvpn.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_udp_egress" {
  rule_type   = "egress"
  from_port   = 0
  to_port     = 65535
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "udp"
  sg_id       = "${module.sg_openvpn.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "iam_policy_openvpn" {
  policy_name        = "openvpn"
  policy_description = "openvpn"
  source             = "github.com/Trility/tf-aws-modules//iam_policy"

  policy = <<POLICY
{
    "Statement": [
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.account_name}-openvpn"
            ]
        },
        {
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.account_name}-openvpn/*"
            ]
        }
    ],
    "Version": "2012-10-17"
}
POLICY
}

module "iam_role_openvpn" {
  role_name = "openvpn"
  source    = "github.com/Trility/tf-aws-modules//iam_role"
}

module "iam_role_openvpn_attach_policy" {
  role_name  = "${module.iam_role_openvpn.role_name}"
  policy_arn = "${module.iam_policy_openvpn.policy_arn}"
  source     = "github.com/Trility/tf-aws-modules//iam_role_policy_attachment"
}

module "iam_role_openvpn_attach_base_infra_policy" {
  role_name  = "${module.iam_role_openvpn.role_name}"
  policy_arn = "arn:aws:iam::${var.account_id}:policy/base_infra"
  source     = "github.com/Trility/tf-aws-modules//iam_role_policy_attachment"
}

module "iam_instance_profile_openvpn" {
  profile_name = "openvpn"
  roles        = ["${module.iam_role_openvpn.role_name}"]
  source       = "github.com/Trility/tf-aws-modules//iam_instance_profile"
}

module "ec2_openvpn" {
  account_name           = "${var.account_name}"
  ami_id                 = "${var.ami_id}"
  aws_keypair            = "${var.aws_keypair}"
  aws_region             = "${var.aws_region}"
  chef_policy            = "${var.chef_policy}"
  chef_policy_group      = "${var.chef_policy_group}"
  chef_server            = "${var.chef_server}"
  chef_server_url        = "${var.chef_server_url}"
  instance_name          = "openvpn"
  instance_profile       = "${module.iam_instance_profile_openvpn.profile_name}"
  instance_type          = "${var.instance_type}"
  lvm_snapshot_id        = "${var.lvm_snapshot_id}"
  snapshots              = "yes"
  subnet                 = "${var.subnet}"
  termination_protection = "true"
  vpc_security_group_ids = ["${module.sg_openvpn.sg_id}", "${var.sg_ssh_id}"]
  source                 = "github.com/Trility/tf-aws-modules//ec2_instance"
}
