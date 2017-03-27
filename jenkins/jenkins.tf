data "aws_caller_identity" "current" {}

data "aws_security_group" "ssh" {
  filter {
    name   = "tag:Name"
    values = ["infra-ssh"]
  }
}

variable "account_name" {}
variable "subnet" {}
variable "vpc" {}
variable "vpc_cidr" {}

module "jenkins_bucket" {
  bucket_logging = "${var.account_name}-logs-s3"
  bucket_name    = "${var.account_name}-jenkins"
  logging_prefix = "${var.account_name}-jenkins/"
  source         = "github.com/Trility/tf-aws-modules//s3_bucket"
}

module "sg_jenkins" {
  group_name        = "jenkins"
  group_description = "jenkins"
  vpc_id            = "${var.vpc}"
  source            = "github.com/Trility/tf-aws-modules//sg"
}

module "sg_8443_tcp_ingress" {
  rule_type   = "ingress"
  from_port   = 8443
  to_port     = 8443
  cidr_blocks = ["${var.vpc_cidr}"]
  protocol    = "tcp"
  sg_id       = "${module.sg_jenkins.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_2049_tcp_ingress" {
  rule_type   = "ingress"
  from_port   = 2049
  to_port     = 2049
  cidr_blocks = ["${var.vpc_cidr}"]
  protocol    = "tcp"
  sg_id       = "${module.sg_jenkins.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "efs_jenkins" {
  name   = "jenkins"
  source = "github.com/Trility/tf-aws-modules//efs_file_system"
}

module "efs_mount_target_jenkins" {
  file_system_id  = "${module.efs_jenkins.id}"
  security_groups = ["${module.sg_jenkins.sg_id}"]
  subnet_id       = "${var.subnet}"
  source          = "github.com/Trility/tf-aws-modules//efs_mount_target"
}

module "iam_policy_jenkins" {
  policy_name        = "jenkins"
  policy_description = "jenkins"
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
                "arn:aws:s3:::${var.account_name}-jenkins"
            ]
        },
        {
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.account_name}-jenkins/*"
            ]
        }
    ],
    "Version": "2012-10-17"
}
POLICY
}

module "iam_role_jenkins" {
  role_name = "jenkins"
  source    = "github.com/Trility/tf-aws-modules//iam_role"
}

module "iam_role_jenkins_attach_policy" {
  role_name  = "${module.iam_role_jenkins.role_name}"
  policy_arn = "${module.iam_policy_jenkins.policy_arn}"
  source     = "github.com/Trility/tf-aws-modules//iam_role_policy_attachment"
}

module "iam_role_jenkins_attach_base_infra_policy" {
  role_name  = "${module.iam_role_jenkins.role_name}"
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/base_infra"
  source     = "github.com/Trility/tf-aws-modules//iam_role_policy_attachment"
}

module "iam_instance_profile_jenkins" {
  profile_name = "jenkins"
  roles        = ["${module.iam_role_jenkins.role_name}"]
  source       = "github.com/Trility/tf-aws-modules//iam_instance_profile"
}
