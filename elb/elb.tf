variable "elb_cipher_policy" {
  default = "ELBSecurityPolicy-2016-08"
}

variable "elb_logs_bucket" {}
variable "elb_logs_bucket_prefix" {}

variable "elb_logs_interval" {
  default = 5
}

variable "elb_name" {}
variable "elb_port" {}

variable "elb_protocol" {
  default = "SSL"
}

variable "elb_security_groups" {
  type = "list"
}

variable "elb_subnets" {
  type = "list"
}

variable "healthy_threshold" {
  default = 10
}

variable "instance_port" {}

variable "instance_protocol" {
  default = "TCP"
}

variable "internal" {}

variable "interval" {
  default = 30
}

variable "ssl_certificate" {}

variable "timeout" {
  default = 5
}

variable "unhealthy_threshold" {
  default = 2
}

output "elb_id" {
  value = "${aws_elb.elb.id}"
}

output "elb_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}

resource "aws_elb" "elb" {
  name = "${var.elb_name}"

  access_logs {
    bucket        = "${var.elb_logs_bucket}"
    bucket_prefix = "${var.elb_logs_bucket_prefix}"
    interval      = "${var.elb_logs_interval}"
  }

  listener {
    instance_port      = "${var.instance_port}"
    instance_protocol  = "${var.instance_protocol}"
    lb_port            = "${var.elb_port}"
    lb_protocol        = "${var.elb_protocol}"
    ssl_certificate_id = "${var.ssl_certificate}"
  }

  health_check {
    healthy_threshold   = "${var.healthy_threshold}"
    unhealthy_threshold = "${var.unhealthy_threshold}"
    timeout             = "${var.timeout}"
    target              = "${var.instance_protocol}:${var.instance_port}"
    interval            = "${var.interval}"
  }

  security_groups = ["${var.elb_security_groups}"]
  subnets         = ["${var.elb_subnets}"]
  internal        = "${var.internal}"
}

resource "aws_load_balancer_listener_policy" "latest" {
  load_balancer_name = "${aws_elb.elb.name}"
  load_balancer_port = "${var.elb_port}"

  policy_names = [
    "${var.elb_cipher_policy}",
  ]

  depends_on = ["aws_elb.elb"]
}
