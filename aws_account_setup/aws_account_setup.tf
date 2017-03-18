data "aws_iam_account_alias" "current" {}

variable "account_name" {}

variable "billing_admins" {
  type = "list"
}

variable "admins" {
  type = "list"
}

variable "super_admins" {
  type = "list"
}

module "password_settings" {
  source = "../iam_account_password_policy"
}

module "iam_group_super_admins" {
  group_members = ["${var.super_admins}"]
  group_name    = "${var.account_name}_super_admins"
  policy_arn    = "arn:aws:iam::aws:policy/AdministratorAccess"
  source        = "../../modules/iam_group"
}

module "iam_group_admins" {
  group_members = ["${var.admins}"]
  group_name    = "${var.account_name}_admins"
  policy_arn    = "arn:aws:iam::aws:policy/AdministratorAccess"
  source        = "../../modules/iam_group"
}

module "iam_billing_admins" {
  group_members = ["${var.billing_admins}"]
  group_name    = "${var.account_name}_billing_admins"
  policy_arn    = "arn:aws:iam::aws:policy/job-function/Billing"
  source        = "../../modules/iam_group"
}

module "iam_policy_user_management" {
  policy_name        = "user_management"
  policy_description = "user_management"
  source             = "../iam_policy"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "iam:*VirtualMFADevice"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:iam::${data.aws_iam_account_alias.current.account_alias}:mfa/$${aws:username}"
            ],
            "Sid": "AllowUsersToCreateDeleteTheirOwnVirtualMFADevices"
        },
        {
            "Action": [
                "iam:DeactivateMFADevice",
                "iam:EnableMFADevice",
                "iam:ListMFADevices",
                "iam:ResyncMFADevice"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:iam::${data.aws_iam_account_alias.current.account_alias}:user/$${aws:username}"
            ],
            "Sid": "AllowUsersToEnableSyncDisableTheirOwnMFADevices"
        },
        {
            "Action": [
                "iam:ListVirtualMFADevices"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:iam::${data.aws_iam_account_alias.current.account_alias}:mfa/*"
            ],
            "Sid": "AllowUsersToListVirtualMFADevices"
        },
        {
            "Action": [
                "iam:ListUsers"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:iam::${data.aws_iam_account_alias.current.account_alias}:user/*"
            ],
            "Sid": "AllowUsersToListUsersOnConsole"
        },
        {
            "Action": [
                "iam:*LoginProfile",
                "iam:*AccessKey*",
                "iam:*SigningCertificate*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:iam::${data.aws_iam_account_alias.current.account_alias}:user/$${aws:username}"
            ],
            "Sid": "AllowUsersToManageCredentials"
        },
        {
            "Action": [
                "iam:GetAccount*",
                "iam:ListAccount*"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Sid": "AllowUsersToViewStatsOnConsole"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

module "attach_user_management_to_billing" {
  group      = "${module.iam_billing_admins.group_name}"
  policy_arn = "${module.iam_policy_user_management.policy_arn}"
  source     = "../iam_group_policy_attachment"
}

module "cloudtrail" {
  account_name = "${var.account_name}"
  source       = "../cloudtrail"
}

module "config" {
  account_name = "${var.account_name}"
  source       = "../config"
}
