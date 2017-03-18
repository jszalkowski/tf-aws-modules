variable "rds_subnet_group_name" {}

variable "subnet_ids" {
  type = "list"
}

variable "rds_subnet_group_description" {}
variable "jenkins_build" {}

output "rds_subnet_group_id" {
  value = "${aws_db_subnet_group.rds_subnet_group.id}"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.rds_subnet_group_name}"
  subnet_ids  = ["${var.subnet_ids}"]
  description = "${var.rds_subnet_group_description}"

  tags {
    jenkins_build = "${var.jenkins_build}"
  }
}
