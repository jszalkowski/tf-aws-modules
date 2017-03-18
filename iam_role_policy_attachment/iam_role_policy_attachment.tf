variable "role_name" {}
variable "policy_arn" {}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = "${var.role_name}"
  policy_arn = "${var.policy_arn}"
}
