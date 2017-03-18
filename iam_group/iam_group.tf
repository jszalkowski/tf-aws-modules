variable "group_members" {
  type = "list"
}

variable "group_name" {}

variable "policy_arn" {}

output "group_name" {
  value = "${aws_iam_group.group.name}"
}

resource "aws_iam_group" "group" {
  name = "${var.group_name}"
}

resource "aws_iam_group_membership" "members" {
  name  = "${var.group_name}-members"
  users = ["${var.group_members}"]
  group = "${aws_iam_group.group.name}"
}

resource "aws_iam_group_policy_attachment" "attach" {
  group      = "${aws_iam_group.group.name}"
  policy_arn = "${var.policy_arn}"
}
