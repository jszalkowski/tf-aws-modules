variable "group" {}
variable "policy_arn" {}

resource "aws_iam_group_policy_attachment" "attach" {
  group      = "${var.group}"
  policy_arn = "${var.policy_arn}"
}
