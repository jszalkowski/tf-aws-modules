variable "provider_tag" {}
variable "vpc_peering_connection_id" {}

variable "auto_accept" {
  default = true
}

variable "peering_connection_name" {}

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = "${var.provider_tag}"
  vpc_peering_connection_id = "${var.vpc_peering_connection_id}"
  auto_accept               = "${var.auto_accept}"

  tags {
    Name = "${var.peering_connection_name}_accepter"
  }
}
