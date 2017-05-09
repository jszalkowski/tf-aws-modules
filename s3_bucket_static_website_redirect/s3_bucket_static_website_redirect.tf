variable "redirect_address" {}

variable "bucket_name" {}

output "bucket_id" {
  value = "${aws_s3_bucket.bucket.id}"
}

output "website_endpoint_url" {
  value = "${aws_s3_bucket.bucket.website_endpoint}"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl = "public-read"

  website {
    redirect_all_requests_to = "${var.redirect_address}"
  }

  tags {
    Name = "${var.bucket_name}"
  }
}
