variable "profile_name" {}

variable "roles" {
  type = "list"
}

output "profile_name" {
  value = "${aws_iam_instance_profile.profile.name}"
}

resource "aws_iam_instance_profile" "profile" {
  name  = "${var.profile_name}"
  roles = ["${var.roles}"]
}
