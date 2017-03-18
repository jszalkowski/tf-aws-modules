variable "policy_name" {}
variable "policy_description" {}
variable "policy" {}

output "policy_id" {
  value = "${aws_iam_policy.policy.id}"
}

output "policy_arn" {
  value = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_policy" "policy" {
  name        = "${var.policy_name}"
  description = "${var.policy_description}"
  policy      = "${var.policy}"
}
