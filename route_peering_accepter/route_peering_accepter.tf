variable "route_table_id" {}
variable "destination_cidr_block" {}
variable "peering_id" {}

resource "aws_route" "route_peering" {
  provider                  = "aws.peer"
  route_table_id            = "${var.route_table_id}"
  destination_cidr_block    = "${var.destination_cidr_block}"
  vpc_peering_connection_id = "${var.peering_id}"
}
