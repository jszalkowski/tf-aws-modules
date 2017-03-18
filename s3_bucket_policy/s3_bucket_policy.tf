variable "bucket_id" {}
variable "s3_policy" {}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = "${var.bucket_id}"
  policy = "${var.s3_policy}"
}
