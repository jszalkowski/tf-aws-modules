variable "health_check_healthy_threshold" {
  default = 5
}

variable "health_check_interval" {
  default = 30
}

variable "health_check_matcher" {
  default = 200
}

variable "health_check_path" {
  default = "/"
}

variable "health_check_port" {
  default = "traffic-port"
}

variable "health_check_protocol" {
  default = "HTTP"
}

variable "health_check_timeout" {
  default = 5
}

variable "health_check_unhealthy_threshold" {
  default = 2
}

variable "name" {}
variable "port" {}
variable "protocol" {}
variable "vpc_id" {}

output "target_group_arn" {
  value = "${aws_alb_target_group.target_group.arn}"
}

resource "aws_alb_target_group" "target_group" {
  health_check {
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    interval            = "${var.health_check_interval}"
    matcher             = "${var.health_check_matcher}"
    path                = "${var.health_check_path}"
    port                = "${var.health_check_port}"
    protocol            = "${var.health_check_protocol}"
    timeout             = "${var.health_check_timeout}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
  }

  name     = "${var.name}"
  port     = "${var.port}"
  protocol = "${var.protocol}"

  tags {
    Name = "${var.name}"
  }

  vpc_id = "${var.vpc_id}"
}
