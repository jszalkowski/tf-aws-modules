variable "account_name" {}

module "config_bucket" {
  bucket_name = "${var.account_name}-config"
  source      = "../s3_bucket_no_logging"
}

module "config_bucket_policy" {
  bucket_id = "${module.config_bucket.name}"
  source    = "../s3_bucket_policy"

  s3_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSConfigBucketPermissionsCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": [
         "config.amazonaws.com"
        ]
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${var.account_name}-config"
    },
    {
      "Sid": " AWSConfigBucketDelivery",
      "Effect": "Allow",
      "Principal": {
        "Service": [
         "config.amazonaws.com"    
        ]
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.account_name}-config/*",
      "Condition": { 
        "StringEquals": { 
          "s3:x-amz-acl": "bucket-owner-full-control" 
        }
      }
    }
  ]
}
POLICY
}

module "config_role" {
  role_name    = "config"
  role_service = "config"
  source       = "../iam_role"
}

module "config_policy" {
  policy_name        = "config"
  policy_description = "config"
  source             = "../iam_policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${module.config_bucket.arn}",
        "${module.config_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

module "config_role_attachment" {
  policy_arn = "${module.config_policy.policy_arn}"
  role_name  = "${module.config_role.role_name}"
  source     = "../iam_role_policy_attachment"
}

resource "aws_config_delivery_channel" "channel" {
  name           = "${var.account_name}"
  s3_bucket_name = "${module.config_bucket.name}"
  depends_on     = ["aws_config_configuration_recorder.recorder"]
}

resource "aws_config_configuration_recorder" "recorder" {
  name = "${var.account_name}"

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  role_arn = "${module.config_role.role_arn}"
}

resource "aws_config_configuration_recorder_status" "status" {
  name       = "${aws_config_configuration_recorder.recorder.name}"
  is_enabled = true
  depends_on = ["aws_config_delivery_channel.channel"]
}
