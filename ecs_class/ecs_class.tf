variable "app_env" {}
variable "app_name" {}
variable "aws_account_number" {}
variable "base_policy_arn" {}
variable "dc_sg" {}

variable "desired_capacity" {
  default = 3
}

variable "ds_policy_name" {}
variable "env_short" {}
variable "graphite_host" {}

variable "health_check_grace_period" {
  default = 30
}

variable "health_check_type" {
  default = "EC2"
}

variable "ids_server" {}
variable "image_id" {}
variable "infra_cidr_block" {}
variable "instance_type" {}
variable "key_name" {}

variable "max_size" {
  default = 4
}

variable "min_size" {
  default = 3
}

variable "sg_base" {}
variable "vpc_cidr_block" {}
variable "vpc_id" {}

variable "vpc_zone_identifier" {
  type = "list"
}

output "asg_name" {
  value = "${aws_cloudformation_stack.asg.outputs}"
}

output "launch_configuration" {
  value = "${module.launch_config.launch_configuration}"
}

output "iam_role_ecs_arn" {
  value = "${module.iam_role_ecs.role_arn}"
}

output "ecs_cluster_id" {
  value = "${module.ecs_cluster.cluster_id}"
}

output "ecs_min_size" {
  value = "${var.min_size}"
}

module "iam_policy_ecs" {
  policy_name        = "${var.app_env}-${var.app_name}-ecs"
  policy_description = "${var.app_env}-${var.app_name}-ecs"
  source             = "github.com/Trility/tf-aws-modules//iam_policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ecs:DeregisterContainerInstance",
                "ecs:RegisterContainerInstance",
                "ecs:Submit*"
            ],
            "Resource": "arn:aws:ecs:us-west-2:${var.aws_account_number}:cluster/${var.app_env}-${var.app_name}",
            "Effect": "Allow"
        }
     ]
}
EOF
}

module "iam_role_ecs" {
  role_name = "${var.app_env}-${var.app_name}"
  source    = "github.com/Trility/tf-aws-modules//iam_role"
}

module "iam_role_policy_attachment_ecs" {
  role_name  = "${module.iam_role_ecs.role_name}"
  policy_arn = "${module.iam_policy_ecs.policy_arn}"
  source     = "github.com/Trility/tf-aws-modules//iam_role_policy_attachment"
}

module "iam_role_policy_attachment_base" {
  role_name  = "${module.iam_role_ecs.role_name}"
  policy_arn = "${var.base_policy_arn}"
  source     = "github.com/Trility/tf-aws-modules//iam_role_policy_attachment"
}

module "iam_instance_profile_ecs" {
  profile_name = "${var.app_env}-${var.app_name}"
  roles        = ["${module.iam_role_ecs.role_name}"]
  source       = "github.com/Trility/tf-aws-modules//iam_instance_profile"
}

module "ecs_cluster" {
  cluster_name = "${var.app_env}-${var.app_name}"
  source       = "github.com/Trility/tf-aws-modules//ecs_cluster"
}

module "launch_config" {
  app_name             = "${var.app_name}"
  ds_policy_name       = "${var.ds_policy_name}"
  env_short            = "${var.env_short}"
  graphite_host        = "${var.graphite_host}"
  iam_instance_profile = "${module.iam_instance_profile_ecs.profile_name}"
  ids_server           = "${var.ids_server}"
  image_id             = "${var.image_id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.key_name}"
  launch_config_name   = "${var.app_env}-${var.app_name}"
  lc_env               = "${var.app_env}"
  security_groups      = ["${module.sg_ecs.sg_id}", "${var.sg_base}"]
  source               = "github.com/Trility/tf-aws-modules//launch_configuration"
}

resource "aws_cloudformation_stack" "asg" {
  name = "${var.app_env}-${var.app_name}"

  template_body = <<STACK
{
    "Outputs": {
        "ASGName": {
            "Value": {
                "Ref": "${var.app_name}"
            }
        }
    },
    "Resources": {
        "${var.app_name}": {
            "Properties": {
                "DesiredCapacity": "${var.desired_capacity}",
                "HealthCheckGracePeriod": "${var.health_check_grace_period}",
                "HealthCheckType": "${var.health_check_type}",
                "LaunchConfigurationName": "${module.launch_config.launch_configuration}",
                "MaxSize": "${var.max_size}",
                "MinSize": "${var.min_size}",
                "Tags": [
                    {
                        "Key": "Name",
                        "PropagateAtLaunch": true,
                        "Value": "${var.app_env}-${var.app_name}"
                    }
                ],
                "VPCZoneIdentifier": [
                    "${var.vpc_zone_identifier[0]}",
                    "${var.vpc_zone_identifier[1]}",
                    "${var.vpc_zone_identifier[2]}"
                ]
            },
            "Type": "AWS::AutoScaling::AutoScalingGroup",
            "UpdatePolicy": {
                "AutoScalingRollingUpdate": {
                    "MinInstancesInService": "1",
                    "PauseTime": "PT30M",
                    "WaitOnResourceSignals": true
                }
            }
        }
    }
}
STACK
}

module "sg_ecs" {
  group_name        = "${var.app_env}-${var.app_name}"
  group_description = "${var.app_env}-${var.app_name}"
  vpc_id            = "${var.vpc_id}"
  source            = "github.com/Trility/tf-aws-modules//sg"
}

module "sg_ecs_ingress_cidr_rule" {
  rule_type   = "ingress"
  from_port   = 8000
  to_port     = 9999
  cidr_blocks = ["${var.infra_cidr_block}", "${var.vpc_cidr_block}"]
  sg_id       = "${module.sg_ecs.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_ecs_3000_ingress_cidr_rule" {
  rule_type   = "ingress"
  from_port   = 3000
  to_port     = 3000
  cidr_blocks = ["${var.infra_cidr_block}", "${var.vpc_cidr_block}"]
  sg_id       = "${module.sg_ecs.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}

module "sg_ecs_egress_cidr_rule" {
  rule_type   = "egress"
  from_port   = 8000
  to_port     = 9999
  cidr_blocks = ["${var.vpc_cidr_block}"]
  sg_id       = "${module.sg_ecs.sg_id}"
  source      = "github.com/Trility/tf-aws-modules//sg_rule_cidr"
}
