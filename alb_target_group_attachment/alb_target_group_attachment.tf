variable "target_group_arn" {}
variable "target_id" {}
variable "port" {}

resource "aws_alb_target_group_attachment" "target_group_attachment" {
  port             = "${var.port}"
  target_group_arn = "${var.target_group_arn}"
  target_id        = "${var.target_id}"
}
