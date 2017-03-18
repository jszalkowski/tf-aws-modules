variable "vpc_id" {}

variable "route_table_ids" {
  type = "list"
}

variable "service_name" {
  default = "com.amazonaws.us-west-2.s3"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = "${var.vpc_id}"
  route_table_ids = ["${var.route_table_ids}"]
  service_name    = "${var.service_name}"
}
