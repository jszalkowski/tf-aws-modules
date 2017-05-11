variable "alb_arn" {}
variable "certificate_arn" {}
variable "port" {}
variable "protocol" {}
variable "ssl_policy" {}
variable "target_group_arn" {}

output "listener_arn" {
  value = "${aws_alb_listener.listener.arn}"
}

resource "aws_alb_listener" "listener" {
  certificate_arn = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${var.target_group_arn}"
    type             = "forward"
  }

  load_balancer_arn = "${var.alb_arn}"
  port              = "${var.port}"
  protocol          = "${var.protocol}"
  ssl_policy        = "${var.ssl_policy}"
}
