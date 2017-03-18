variable "availability_zones" {
  type = "list"
}

variable "backup_retention_period" {
  default = 5
}

variable "cluster_identifier" {}

variable "db_cluster_parameter_group_name" {}

variable "db_name" {
  default = "admin_db"
}

variable "db_subnet_group_name" {}

variable "master_password" {}

variable "master_username" {
  default = "pithosadmin"
}

variable "preferred_backup_window" {
  default = "05:00-06:00"
}

variable "preferred_maintenance_window" {
  default = "Sat:07:00-Sat:08:00"
}

variable "vpc_security_group_ids" {
  type = "list"
}

output "cluster_id" {
  value = "${aws_rds_cluster.rds_cluster.id}"
}

resource "aws_rds_cluster" "rds_cluster" {
  availability_zones              = ["${var.availability_zones}"]
  backup_retention_period         = "${var.backup_retention_period}"
  cluster_identifier              = "${var.cluster_identifier}"
  database_name                   = "${var.db_name}"
  db_cluster_parameter_group_name = "${var.db_cluster_parameter_group_name}"
  db_subnet_group_name            = "${var.db_subnet_group_name}"
  master_password                 = "${var.master_password}"
  master_username                 = "${var.master_username}"
  preferred_backup_window         = "${var.preferred_backup_window}"
  preferred_maintenance_window    = "${var.preferred_maintenance_window}"
  vpc_security_group_ids          = ["${var.vpc_security_group_ids}"]
}
