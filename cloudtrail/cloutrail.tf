variable "account_name" {}

module "cloudtrail_bucket" {
  bucket_name = "${var.account_name}-cloudtrail"
  source      = "github.com/Trility/tf-aws-modules//s3_bucket_no_logging"
}

module "cloudtrail_bucket_policy" {
  bucket_id = "${module.cloudtrail_bucket.name}"
  source    = "github.com/Trility/tf-aws-modules//s3_bucket_policy"

  s3_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.account_name}-cloudtrail"
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.account_name}-cloudtrail/*",
            "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}
        }
    ]
}
POLICY
}

resource "aws_cloudtrail" "default" {
  is_multi_region_trail = true
  name                  = "${var.account_name}"
  s3_bucket_name        = "${module.cloudtrail_bucket.name}"
  s3_key_prefix         = "${var.account_name}"
  depends_on            = ["module.cloudtrail_bucket_policy"]
}
