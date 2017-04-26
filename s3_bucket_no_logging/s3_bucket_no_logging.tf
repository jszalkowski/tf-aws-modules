variable "bucket_acl" {
  default = "private"
}

variable "bucket_name" {}

variable "bucket_versioning" {
  default = false
}

variable "lifecycle_days" {
  default = "30"
}

variable "lifecycle_enabled" {
  default = false
}

variable "lifecycle_prefix" {
  default = ""
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

  lifecycle_rule {
    prefix = "${var.lifecycle_prefix}"
    enabled = "${var.lifecycle_enabled}"

    expiration {
      days = "${var.lifecycle_days}"
    }
  }

  versioning {
    enabled = "${var.bucket_versioning}"
  }

  tags {
    Name = "${var.bucket_name}"
  }
}
