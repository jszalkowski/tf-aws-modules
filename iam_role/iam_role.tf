variable "role_name" {}

variable "role_path" {
  default = "/"
}

variable "role_service" {
  default = "ec2"
}

output "role_name" {
  value = "${aws_iam_role.role.name}"
}

output "role_arn" {
  value = "${aws_iam_role.role.arn}"
}

resource "aws_iam_role" "role" {
  name = "${var.role_name}"
  path = "${var.role_path}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "${var.role_service}.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
