variable "vpc_id" {}
variable "igw_name" {}

output "igw_id" {
  value = "${aws_internet_gateway.igw.id}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.igw_name}"
  }
}
