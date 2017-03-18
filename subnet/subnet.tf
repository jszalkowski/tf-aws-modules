variable "vpc_id" {}
variable "subnet_name" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}

output "subnet_id" {
  value = "${aws_subnet.subnet.id}"
}

resource "aws_subnet" "subnet" {
  vpc_id                  = "${var.vpc_id}"
  map_public_ip_on_launch = false
  cidr_block              = "${var.subnet_cidr_block}"
  availability_zone       = "${var.availability_zone}"

  tags {
    Name = "${var.subnet_name}"
  }
}
