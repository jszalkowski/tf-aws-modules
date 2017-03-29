variable "name" {}
variable "password" {}

variable "subnets" {
  type = "list"
}

variable "type" {
  default = "MicrosoftAD"
}

variable "vpc" {}

output "id" {
  value = "${aws_directory_service_directory.ad.id}"
}

output "dns_ip_addresses" {
  value = ["${aws_directory_service_directory.ad.dns_ip_addresses}"]
}

resource "aws_directory_service_directory" "ad" {
  name     = "${var.name}"
  password = "${var.password}"
  type     = "${var.type}"

  vpc_settings {
    vpc_id     = "${var.vpc}"
    subnet_ids = ["${var.subnets}"]
  }
}
