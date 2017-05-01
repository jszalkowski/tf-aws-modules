data "aws_iam_account_alias" "current" {}

variable "account_name" {}
variable "account_name_infra_bucket" {}

module "password_settings" {
  source = "github.com/Trility/tf-aws-modules//iam_account_password_policy"
}

module "iam_policy_user_management" {
  policy_name        = "user_management"
  policy_description = "user_management"
  source             = "github.com/Trility/tf-aws-modules//iam_policy"

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
        },
        {
            "Sid": "BlockAnyAccessOtherThanAboveUnlessSignedInWithMFA",
            "Effect": "Deny",
            "NotAction": "iam:*",
            "Resource": "*",
            "Condition":{ "BoolIfExists":{ "aws:MultiFactorAuthPresent": "false"}}
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

module "cloudtrail" {
  account_name = "${var.account_name}"
  source       = "github.com/Trility/tf-aws-modules//cloudtrail"
}

module "config" {
  account_name = "${var.account_name}"
  source       = "github.com/Trility/tf-aws-modules//config"
}

module "backup_bucket" {
  bucket_logging = "${var.account_name}-logs-s3"
  bucket_name    = "${var.account_name}-backups"
  logging_prefix = "${var.account_name}-backups/"
  source         = "github.com/Trility/tf-aws-modules//s3_bucket"
}

module "iam_policy_base" {
  policy_name        = "base"
  policy_description = "base"
  source             = "github.com/Trility/tf-aws-modules//iam_policy"

  policy = <<POLICY
{
    "Statement": [
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.account_name}-*",
                "arn:aws:s3:::${var.account_name_infra_bucket}-infra"
            ]
        },
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.account_name_infra_bucket}-infra/*"
            ]
        },
        {
            "Action": [
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.account_name}-backups/*"
            ]
        },
        {
            "Action": [
                "s3:Put*",
                "s3:Get*",
                "s3:List*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.account_name}-logs-infra*"
            ]
        },
        {
            "Action": [
                "autoscaling:Describe*",
                "cloudwatch:PutMetricData*",
                "ec2:CreateTags",
                "ec2:Describe*",
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "opsworks-cm:AssociateNode",
                "opsworks-cm:DescribeNodeAssociationStatus",
                "opsworks-cm:DescribeServers",
                "ssm:Describe*",
                "ssm:GetDocument",
                "ssm:List*",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ],
    "Version": "2012-10-17"
}
POLICY
}

module "iam_role_base" {
  role_name = "base"
  source    = "github.com/Trility/tf-aws-modules//iam_role"
}

module "iam_role_base_attach_policy" {
  role_name  = "${module.iam_role_base.role_name}"
  policy_arn = "${module.iam_policy_base.policy_arn}"
  source     = "github.com/Trility/tf-aws-modules//iam_role_policy_attachment"
}

module "iam_instance_profile_base" {
  profile_name = "base"
  role        = "${module.iam_role_base.role_name}"
  source       = "github.com/Trility/tf-aws-modules?ref=aws_profile_role_fix//iam_instance_profile"
}
