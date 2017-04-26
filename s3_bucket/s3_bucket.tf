variable "bucket_acl" {
  default = "private"
}

variable "bucket_logging" {}

variable "bucket_name" {}

variable "bucket_versioning" {
  default = true
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

variable "logging_prefix" {}

output "bucket_id" {
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

  logging {
    target_bucket = "${var.bucket_logging}"
    target_prefix = "${var.logging_prefix}"
  }

  versioning {
    enabled = "${var.bucket_versioning}"
  }

  tags {
    Name = "${var.bucket_name}"
  }
}
