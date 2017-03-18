variable "vpc_id" {}
variable "rt_name" {}

output "route_table_id" {
  value = "${aws_route_table.rt.id}"
}

resource "aws_route_table" "rt" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.rt_name}"
  }
}
