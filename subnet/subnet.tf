variable "availability_zone" {}

variable "map_public_ip" {
  default = "false"
}

variable "subnet_cidr_block" {}
variable "subnet_name" {}
variable "vpc_id" {}

output "subnet_id" {
  value = "${aws_subnet.subnet.id}"
}

resource "aws_subnet" "subnet" {
  vpc_id                  = "${var.vpc_id}"
  map_public_ip_on_launch = "${var.map_public_ip}"
  cidr_block              = "${var.subnet_cidr_block}"
  availability_zone       = "${var.availability_zone}"

  tags {
    Name = "${var.subnet_name}"
  }
}
