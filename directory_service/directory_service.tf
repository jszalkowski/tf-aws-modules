variable "name" {}
variable "password" {}

variable "subnets" {
  type = "list"
}

variable "type" {
  default = "MicrosoftAD"
}

variable "vpc" {}

resource "aws_directory_service_directory" "ad" {
  name     = "${var.name}"
  password = "${var.password}"
  type     = "${var.type}"

  vpc_settings {
    vpc_id     = "${var.vpc}"
    subnet_ids = ["${var.subnets}"]
  }
}
