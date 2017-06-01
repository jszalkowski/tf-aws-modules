variable "bucket" {}

variable "key" {}

variable "object_source" {}

resource "aws_s3_bucket_object" "object" {
  bucket = "${var.bucket}"
  key    = "${var.key}"
  source = "${var.object_source}"
}
