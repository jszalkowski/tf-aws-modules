variable "db_parameter_group_name" {}

variable "db_parameter_group_family" {
  default = "aurora5.6"
}

variable "autocommit" {
  default = 0
}

variable "connect_timeout" {
  default = 10
}

variable "general_log" {
  default = 0
}

variable "slow_query_log" {
  default = 1
}

variable "innodb_large_prefix" {
  default = 0
}

variable "interactive_timeout" {
  default = 400
}

variable "max_allowed_packet" {
  default = 268435456
}

variable "max_connections" {
  default = 1000
}

variable "old_passwords" {
  default = 0
}

variable "wait_timeout" {
  default = 300
}

output "db_parameter_group_id" {
  value = "${aws_db_parameter_group.db_parameter_group.id}"
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "${var.db_parameter_group_name}"
  family = "${var.db_parameter_group_family}"

  parameter {
    name  = "autocommit"
    value = "${var.autocommit}"
  }

  parameter {
    name  = "connect_timeout"
    value = "${var.connect_timeout}"
  }

  parameter {
    name  = "general_log"
    value = "${var.general_log}"
  }

  parameter {
    name  = "slow_query_log"
    value = "${var.slow_query_log}"
  }

  parameter {
    name  = "innodb_large_prefix"
    value = "${var.innodb_large_prefix}"
  }

  parameter {
    name  = "interactive_timeout"
    value = "${var.interactive_timeout}"
  }

  parameter {
    name  = "max_allowed_packet"
    value = "${var.max_allowed_packet}"
  }

  parameter {
    name  = "max_connections"
    value = "${var.max_connections}"
  }

  parameter {
    name  = "old_passwords"
    value = "${var.old_passwords}"
  }

  parameter {
    name  = "wait_timeout"
    value = "${var.wait_timeout}"
  }
}
