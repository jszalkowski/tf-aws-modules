variable "asg_name" {}

variable "desired_capacity" {
  default = 3
}

variable "health_check_grace_period" {
  default = 30
}

variable "health_check_type" {
  default = "EC2"
}

variable "launch_config_id" {}

variable "max_size" {
  default = 4
}

variable "min_size" {
  default = 3
}

variable "vpc_zone_identifier" {
  type = "list"
}

output "autoscaling_group_name" {
  value = "${aws_autoscaling_group.group.name}"
}

output "min_size" {
  value = "${var.min_size}"
}

resource "aws_autoscaling_group" "group" {
  desired_capacity          = "${var.desired_capacity}"
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"
  launch_configuration      = "${var.launch_config_id}"

  lifecycle {
    create_before_destroy = true
  }

  max_size = "${var.max_size}"
  min_size = "${var.min_size}"
  name     = "${var.asg_name}"

  tag = {
    key                 = "Name"
    value               = "${var.asg_name}"
    propagate_at_launch = true
  }

  vpc_zone_identifier = ["${var.vpc_zone_identifier}"]
}
