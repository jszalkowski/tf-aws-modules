variable "cluster_instance_count" {
  default = 1
}

variable "rds_cluster_identifier" {}

variable "db_instance_class" {
  default = "db.t2.medium"
}

variable "db_parameter_group_name" {}
variable "db_subnet_group_name" {}
variable "db_category" {}

variable "db_engine" {
  default = "Aurora"
}

variable "instance_env" {}

resource "aws_rds_cluster_instance" "rds_instance" {
  count                   = "${var.cluster_instance_count}"
  identifier              = "${var.instance_env}-rds${count.index}"
  cluster_identifier      = "${var.rds_cluster_identifier}"
  instance_class          = "${var.db_instance_class}"
  db_parameter_group_name = "${var.db_parameter_group_name}"
  db_subnet_group_name    = "${var.db_subnet_group_name}"

  tags {
    DbCategory = "${var.db_category}"
    DbEngine   = "${var.db_engine}"
    Name       = "${var.instance_env}-aurora-${count.index}"
  }
}
