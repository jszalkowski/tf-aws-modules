variable "rds_pg_name" {}

variable "rds_pg_family" {
  default = "aurora5.6"
}

variable "description" {}

output "rds_parameter_group_id" {
  value = "${aws_rds_cluster_parameter_group.rds_parameter_group.id}"
}

resource "aws_rds_cluster_parameter_group" "rds_parameter_group" {
  name        = "${var.rds_pg_name}"
  family      = "${var.rds_pg_family}"
  description = "${var.description}"

  parameter {
    name  = "time_zone"
    value = "UTC"
  }
}
