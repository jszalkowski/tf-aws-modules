variable "rule_type" {}

variable "protocol" {
  default = "tcp"
}

variable "from_port" {}
variable "to_port" {}
variable "sg_id" {}

variable "cidr_blocks" {
  type = "list"
}

resource "aws_security_group_rule" "sg_rule" {
  type              = "${var.rule_type}"
  protocol          = "${var.protocol}"
  from_port         = "${var.from_port}"
  to_port           = "${var.to_port}"
  security_group_id = "${var.sg_id}"
  cidr_blocks       = ["${var.cidr_blocks}"]
}
