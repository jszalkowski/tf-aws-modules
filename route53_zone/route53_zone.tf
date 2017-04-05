variable "zone_name" {}

output "zone_id" {
  value = "${aws_route53_zone.zone.zone_id}"
}

resource "aws_route53_zone" "zone" {
  name = "${var.zone_name}"
}
