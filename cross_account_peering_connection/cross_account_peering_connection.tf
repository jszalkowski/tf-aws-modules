variable "remote_account_id" {}

variable "remote_vpc_id" {}

variable "remote_cidr_block" {}

variable "remote_public_route_table_id" {}

variable "remote_private_route_table_id" {}

variable "local_vpc_id" {}

variable "local_cidr_block" {}

variable "local_public_route_table_id" {}

variable "local_private_route_table_id" {}

variable "connection_name" {}

module "local_vpc_peering_connection" {
  peer_owner_id           = "${var.remote_account_id}"
  peer_vpc_id             = "${var.remote_vpc_id}"
  vpc_id                  = "${var.local_vpc_id}"
  peering_connection_name = "${var.connection_name}"
  auto_accept             = "false"
  source                  = "github.com/Trility/tf-aws-modules//vpc_peering_connection"
}

module "remote_vpc_accepter" {
  vpc_peering_connection_id = "${module.local_vpc_peering_connection.peering_id}"
  peering_connection_name   = "${var.connection_name}"
  source                    = "github.com/Trility/tf-aws-modules//vpc_peering_connection_accepter"
}

module "remote_route_public" {
  route_table_id         = "${var.remote_public_route_table_id}"
  destination_cidr_block = "${var.local_cidr_block}"
  peering_id             = "${module.local_vpc_peering_connection.peering_id}"
  source                 = "github.com/Trility/tf-aws-modules//route_peering_accepter"
}

module "remote_route_private" {
  route_table_id         = "${var.remote_private_route_table_id}"
  destination_cidr_block = "${var.local_cidr_block}"
  peering_id             = "${module.local_vpc_peering_connection.peering_id}"
  source                 = "github.com/Trility/tf-aws-modules//route_peering_accepter"
}

module "local_route_public" {
  route_table_id         = "${var.local_public_route_table_id}"
  destination_cidr_block = "${var.remote_cidr_block}"
  peering_id             = "${module.local_vpc_peering_connection.peering_id}"
  source                 = "github.com/Trility/tf-aws-modules//route_peering"
}

module "local_route_private" {
  route_table_id         = "${var.local_private_route_table_id}"
  destination_cidr_block = "${var.remote_cidr_block}"
  peering_id             = "${module.local_vpc_peering_connection.peering_id}"
  source                 = "github.com/Trility/tf-aws-modules//route_peering"
}
