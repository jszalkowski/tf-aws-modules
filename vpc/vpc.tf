variable "cidr_block" {}
variable "vpc_name" {}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = "true"

  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_default_security_group" "vpc_default_security_group" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.vpc_name}-default-sg"
  }
}

resource "aws_default_route_table" "vpc_default_route_table" {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"

  tags {
    Name = "${var.vpc_name}-default-rt"
  }
}
