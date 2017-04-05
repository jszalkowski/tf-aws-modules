variable "alias_name" {}

variable "alias_zone_id" {}

variable "alias_target_health" {
  default = "true"
}

variable "zone_name" {}

variable "zone_type" {}

variable "zone_id" {}

resource "aws_route53_record" "record" {
  zone_id = "${var.zone_id}"
  name    = "${var.zone_name}"
  type    = "${var.zone_type}"

  alias {
    name                   = "${var.alias_name}"
    zone_id                = "${var.alias_zone_id}"
    evaluate_target_health = "${var.alias_target_health}"
  }
}
