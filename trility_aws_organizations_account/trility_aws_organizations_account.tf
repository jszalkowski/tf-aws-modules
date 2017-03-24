variable "account_name" {}

variable "email_address" {}

variable "role_name" {}

output "account_id" {
  value = "${trility_aws_organizations_account.account.id}"
}

resource "trility_aws_organizations_account" "account" {
  name      = "${var.account_name}"
  email     = "${var.email_address}"
  role_name = "${var.role_name}"
}
