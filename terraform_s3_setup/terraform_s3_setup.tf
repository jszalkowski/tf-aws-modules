variable "account_name" {}

module "iam_account_alias" {
  alias  = "${var.account_name}"
  source = "github.com/Trility/tf-aws-modules//iam_account_alias"
}

module "logs-s3" {
  bucket_name = "${var.account_name}-logs-s3"
  bucket_acl  = "log-delivery-write"
  source      = "github.com/Trility/tf-aws-modules//s3_bucket_no_logging"
}

module "terraform-s3" {
  bucket_logging = "${var.account_name}-logs-s3"
  bucket_name    = "${var.account_name}-terraform"
  logging_prefix = "${var.account_name}-terraform/"
  source         = "github.com/Trility/tf-aws-modules//s3_bucket"

  /*depends_on     = ["module.logs-s3"]*/
}

module "terraform-s3-policy" {
  bucket_id   = "${module.terraform-s3.bucket_id}"
  bucket_name = "${var.account_name}-terraform"
  source      = "github.com/Trility/tf-aws-modules//s3_bucket_policy_encrypted"
}
