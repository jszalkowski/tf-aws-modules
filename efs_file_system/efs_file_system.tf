variable "name" {}

resource "aws_efs_file_system" "efs" {
  tags {
    Name = "${var.name}"
  }
}
