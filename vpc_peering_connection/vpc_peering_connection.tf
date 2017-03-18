variable "peer_owner_id" {}
variable "peer_vpc_id" {}
variable "vpc_id" {}

variable "auto_accept" {
  default = true
}

variable "peering_connection_name" {}

output "peering_id" {
  value = "${aws_vpc_peering_connection.peering_connection.id}"
}

resource "aws_vpc_peering_connection" "peering_connection" {
  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id   = "${var.peer_vpc_id}"
  vpc_id        = "${var.vpc_id}"
  auto_accept   = "${var.auto_accept}"

  tags {
    Name = "${var.peering_connection_name}"
  }
}
