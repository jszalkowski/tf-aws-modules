variable "name" {}

output "filesystem_id" {
  value = "${aws_efs_file_system.efs.id}"
}

resource "aws_efs_file_system" "efs" {
  tags {
    Name = "${var.name}"
  }
}
