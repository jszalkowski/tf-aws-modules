data "aws_region" "current" {
  current = true
}

data "aws_ip_ranges" "ec2" {
  regions  = ["${data.aws_region.current.name}"]
  services = ["amazon"]
}

data "aws_vpc" "infra" {
  filter {
    name   = "tag:Name"
    values = ["infra"]
  }
}

module "iam_role_opsworks_cm_ec2" {
  role_name = "aws-opsworks-cm-ec2"
  role_path = "/service-role/"
  source    = "github.com/Trility/tf-aws-modules//iam_role"
}

module "iam_role_policy_attachment_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role_name  = "${module.iam_role_opsworks_cm_ec2.role_name}"
  source     = "github.com/Trility/tf-aws-modules//iam_role_policy_attachment"
}

module "iam_role_policy_attachment_s3" {
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCMInstanceProfileRole"
  role_name  = "${module.iam_role_opsworks_cm_ec2.role_name}"
  source     = "github.com/Trility/tf-aws-modules//iam_role_policy_attachment"
}

module "iam_instance_profile_opsworks_cm" {
  profile_name = "aws-opsworks-cm-ec2"
  roles        = ["${module.iam_role_opsworks_cm_ec2.role_name}"]
  source       = "github.com/Trility/tf-aws-modules//iam_instance_profile"
}

module "iam_role_opsworks_service" {
  role_name    = "aws-opsworks-cm-service"
  role_path    = "/service-role/"
  role_service = "opsworks-cm"
  source       = "github.com/Trility/tf-aws-modules//iam_role"
}

module "iam_role_policy_attachment_server" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSOpsWorksCMServiceRole"
  role_name  = "${module.iam_role_opsworks_service.role_name}"
  source     = "github.com/Trility/tf-aws-modules//iam_role_policy_attachment"
}

module "sg_opsworks_cm" {
  group_name        = "opsworks-cm"
  group_description = "opsworks-cm"
  vpc_id            = "${data.aws_vpc.infra.id}"
  source            = "github.com/Trility/tf-aws-modules//sg"
}

module "sg_opsworks_cm_ingress_443_rule" {
  rule_type   = "ingress"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["${data.aws_ip_ranges.ec2.cidr_blocks}"]
  sg_id       = "${module.sg_opsworks_cm.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_opsworks_cm_ingress_8443_rule" {
  rule_type   = "ingress"
  from_port   = 8443
  to_port     = 8443
  cidr_blocks = ["${data.aws_vpc.infra.cidr_block}"]
  sg_id       = "${module.sg_opsworks_cm.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_opsowrks_cm_egress_cidr_rule" {
  rule_type   = "egress"
  from_port   = 0
  to_port     = 65535
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = "all"
  sg_id       = "${module.sg_opsworks_cm.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}
