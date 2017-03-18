variable "iam_user" {}

variable "keybase_user" {
  default = "infra_trility"
}

resource "aws_iam_user" "user" {
  name          = "${var.iam_user}"
  force_destroy = true
}

/*
resource "aws_iam_user_login_profile" "user_profile" {
  user    = "${aws_iam_user.user.name}"
  pgp_key = "keybase:${var.keybase_user}"
}

output "password" {
  value = "${aws_iam_user_login_profile.user_profile.encrypted_password}"
}
*/

