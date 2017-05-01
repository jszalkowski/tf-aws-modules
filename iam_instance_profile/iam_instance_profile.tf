variable "profile_name" {}

variable "role" {
}

output "profile_name" {
  value = "${aws_iam_instance_profile.profile.name}"
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.profile_name}"
  role = "${var.roles}"
}
