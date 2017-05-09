variable "aliases" {
  type = "list"
}

variable "cache_allowed_methods" {
  type = "list"

  default = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
}

variable "certificate_id" {}

variable "domain_name" {}

variable "enabled" {
  default = true
}

variable "locations" {
  type = "list"
}

variable "logging_bucket" {}
variable "name" {}
variable "price_class" {}

variable "restriction_type" {}

variable "target_origin_id" {}

output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.distribution.domain_name}"
}

output "cloudfront_hosted_zone_id" {
  value = "${aws_cloudfront_distribution.distribution.hosted_zone_id}"
}

resource "aws_cloudfront_distribution" "distribution" {
  aliases = ["${var.aliases}"]

  default_cache_behavior {
    allowed_methods = ["${var.cache_allowed_methods}"]
    cached_methods  = ["GET", "HEAD"]
    default_ttl     = 86400

    forwarded_values = {
      cookies {
        forward = "all"
      }

      query_string = true
    }

    max_ttl                = 31536000
    min_ttl                = 0
    target_origin_id       = "${var.target_origin_id}"
    viewer_protocol_policy = "redirect-to-https"
  }

  enabled = "${var.enabled}"

  logging_config {
    bucket          = "${var.logging_bucket}"
    include_cookies = true
    prefix          = "${var.target_origin_id}"
  }

  origin {
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = "${var.domain_name}"
    origin_id   = "${var.target_origin_id}"
  }

  price_class = "${var.price_class}"

  restrictions {
    geo_restriction {
      locations        = ["${var.locations}"]
      restriction_type = "${var.restriction_type}"
    }
  }

  tags {
    Name     = "${var.name}"
    OriginId = "${var.target_origin_id}"
  }

  viewer_certificate {
    iam_certificate_id       = "${var.certificate_id}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
}
