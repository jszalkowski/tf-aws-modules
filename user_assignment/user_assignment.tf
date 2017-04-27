variable "account_name" {}

variable "account_name_infra_bucket" {}

variable "group_name" {}

variable "policy_arn" {}

variable "user_list" {
  type = "list"
}

module "iam_group_assignment" {
  group_members = ["${var.user_list}"]
  group_name    = "${var.account_name}_${var.group_name}"
  policy_arn    = "${var.policy_arn}"
  source        = "github.com/Trility/tf-aws-modules//iam_group"
}
