variable "records" {
  type = "list"
}

variable "ttl" {}

variable "name" {}

variable "zone_type" {}

variable "zone_id" {}

resource "aws_route53_record" "record" {
  zone_id = "${var.zone_id}"
  name    = "${var.name}"
  type    = "${var.zone_type}"
  ttl     = "${var.ttl}"
  records = ["${var.records}"]
}
