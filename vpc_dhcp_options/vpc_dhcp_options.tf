variable "domain_name" {}

variable "dhcp_name" {}

variable "dns_servers" {
  type = "list"
}

variable "netbios_node_type" {
  default = 2
}

variable "ntp_servers" {
  type = "list"
}

resource "aws_vpc_dhcp_options" "dhcp" {
  domain_name          = "${var.domain_name}"
  domain_name_servers  = ["${var.dns_servers}"]
  ntp_servers          = ["${var.ntp_servers}"]
  netbios_name_servers = ["${var.dns_servers}"]
  netbios_node_type    = "${var.netbios_node_type}"

  tags {
    Name = "${var.dhcp_name}"
  }
}
