variable "route_table_id" {}
variable "destination_cidr_block" {}
variable "nat_gw_id" {}

resource "aws_route" "route_nat" {
  route_table_id         = "${var.route_table_id}"
  destination_cidr_block = "${var.destination_cidr_block}"
  nat_gateway_id         = "${var.nat_gw_id}"
}
