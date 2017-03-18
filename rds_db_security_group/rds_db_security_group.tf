variable "db_security_group_name" {}
variable "db_security_group_description" {}
variable "db_security_group_cidr" {}

output "db_security_group_id" {
  value = "${aws_db_security_group.db_security_group.id}"
}

resource "aws_db_security_group" "db_security_group" {
  name        = "${var.db_security_group_name}"
  description = "${var.db_security_group_description}"

  ingress {
    cidr = "${var.db_security_group_cidr}"
  }
}
