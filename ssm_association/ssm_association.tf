variable "instance_id" {}
variable "ssm_document_name" {}

resource "aws_ssm_association" "association" {
  name        = "${var.ssm_document_name}"
  instance_id = "${var.instance_id}"
}
