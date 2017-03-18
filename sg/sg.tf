variable "group_name" {}
variable "group_description" {}
variable "vpc_id" {}

output "sg_id" {
  value = "${aws_security_group.sg.id}"
}

resource "aws_security_group" "sg" {
  name = "${var.group_name}"
  description = "${var.group_description}"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "${var.group_name}"
  }
}
