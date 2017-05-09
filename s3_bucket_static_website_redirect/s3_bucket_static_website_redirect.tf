variable "redirect_address" {}

variable "bucket_name" {}

output "bucket_id" {
  value = "${aws_s3_bucket.bucket.id}"
}

output "website_endpoint_url" {
  value = "${aws_s3_bucket.bucket.website_endpoint}"
}

output "s3_hosted_zone_id" {
  value = "${aws_s3_bucket.bucket.hosted_zone_id}"
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
