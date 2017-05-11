variable "condition_field" {}
variable "condition_values" {}
variable "listener_arn" {}
variable "priority" {}
variable "target_group_arn" {}

resource "aws_alb_listener_rule" "rule" {
  action {
    target_group_arn = "${var.target_group_arn}"
    type             = "forward"
  }

  condition {
    field  = "${var.condition_field}"
    values = ["${var.condition_values}"]
  }

  listener_arn = "${var.listener_arn}"
  priority     = "${var.priority}"
}
