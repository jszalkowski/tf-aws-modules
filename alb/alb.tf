variable "deletion_protection" {
  default = "false"
}

variable "internal" {}

variable "log_bucket" {}

variable "name" {}

variable "security_groups" {
  type = "list"
}

variable "subnets" {
  type = "list"
}

output "alb_arn" {
  value = "${aws_alb.alb.arn}"
}

resource "aws_alb" "alb" {
  access_logs {
    bucket = "${var.log_bucket}"
    prefix = "alb"
  }

  enable_deletion_protection = "${var.deletion_protection}"
  name                       = "${var.name}"
  internal                   = "${var.internal}"
  security_groups            = ["${var.security_groups}"]
  subnets                    = ["${var.subnets}"]

  tags {
    Name = "${var.name}"
  }
}
