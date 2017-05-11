data "aws_caller_identity" "current" {}

variable "account_name" {}
variable "vpc" {}
variable "vpc_cidr" {}

output "instance_profile" {
  value = "${module.iam_instance_profile_vault.profile_name}"
}

output "vault_sg" {
  value = "${module.sg_vault.sg_id}"
}

module "vault_bucket" {
  bucket_logging = "${var.account_name}-logs-s3"
  bucket_name    = "${var.account_name}-vault"
  logging_prefix = "${var.account_name}-vault/"
  source         = "github.com/Trility/tf-aws-modules//s3_bucket"
}

module "sg_vault" {
  group_name        = "vault"
  group_description = "vault"
  vpc_id            = "${var.vpc}"
  source            = "github.com/Trility/tf-aws-modules//sg"
}

module "sg_8080_tcp_ingress" {
  rule_type   = "ingress"
  from_port   = 8080
  to_port     = 8080
  cidr_blocks = ["${var.vpc_cidr}"]
  protocol    = "tcp"
  sg_id       = "${module.sg_vault.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_8200_tcp_ingress" {
  rule_type   = "ingress"
  from_port   = 8200
  to_port     = 8200
  cidr_blocks = ["${var.vpc_cidr}"]
  protocol    = "tcp"
  sg_id       = "${module.sg_vault.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_8300_8302_tcp_ingress" {
  rule_type   = "ingress"
  from_port   = 8300
  to_port     = 8302
  cidr_blocks = ["${var.vpc_cidr}"]
  protocol    = "tcp"
  sg_id       = "${module.sg_vault.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_8400_tcp_ingress" {
  rule_type   = "ingress"
  from_port   = 8400
  to_port     = 8400
  cidr_blocks = ["${var.vpc_cidr}"]
  protocol    = "tcp"
  sg_id       = "${module.sg_vault.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_8500_tcp_ingress" {
  rule_type   = "ingress"
  from_port   = 8500
  to_port     = 8500
  cidr_blocks = ["${var.vpc_cidr}"]
  protocol    = "tcp"
  sg_id       = "${module.sg_vault.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_8600_tcp_ingress" {
  rule_type   = "ingress"
  from_port   = 8600
  to_port     = 8600
  cidr_blocks = ["${var.vpc_cidr}"]
  protocol    = "tcp"
  sg_id       = "${module.sg_vault.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_vault_egress" {
  rule_type   = "egress"
  from_port   = 0
  to_port     = 65535
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "all"
  sg_id       = "${module.sg_vault.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "iam_policy_vault" {
  policy_name        = "vault"
  policy_description = "vault"
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
                "arn:aws:s3:::${var.account_name}-vault"
            ]
        },
        {
            "Action": [
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.account_name}-vault/*"
            ]
        }
    ],
    "Version": "2012-10-17"
}
POLICY
}

module "iam_role_vault" {
  role_name = "vault"
  source    = "github.com/Trility/tf-aws-modules//iam_role"
}

module "iam_role_vault_attach_policy" {
  role_name  = "${module.iam_role_vault.role_name}"
  policy_arn = "${module.iam_policy_vault.policy_arn}"
  source     = "github.com/Trility/tf-aws-modules//iam_role_policy_attachment"
}

module "iam_role_vault_attach_base_policy" {
  role_name  = "${module.iam_role_vault.role_name}"
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/base"
  source     = "github.com/Trility/tf-aws-modules//iam_role_policy_attachment"
}

module "iam_instance_profile_vault" {
  profile_name = "vault"
  role         = "${module.iam_role_vault.role_name}"
  source       = "github.com/Trility/tf-aws-modules//iam_instance_profile"
}
