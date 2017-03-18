variable "bucket_acl" {
  default = "private"
}

variable "bucket_name" {}

variable "bucket_versioning" {
  default = false
}

output "arn" {
  value = "${aws_s3_bucket.bucket.arn}"
}

output "name" {
  value = "${aws_s3_bucket.bucket.id}"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl    = "${var.bucket_acl}"

  versioning {
    enabled = "${var.bucket_versioning}"
  }

  tags {
    Name = "${var.bucket_name}"
  }
}
