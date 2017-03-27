variable "file_system_id" {}

variable "security_groups" {
  type = "list"
}

variable "subnet_id" {}

resource "aws_efs_mount_target" "target" {
  file_system_id  = "${var.file_system_id}"
  security_groups = ["${var.security_groups}"]
  subnet_id       = "${var.subnet_id}"
}
