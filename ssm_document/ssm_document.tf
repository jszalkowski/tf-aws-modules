variable "content" {}
variable "document_type" {}
variable "name" {}

output "ssm_document_name" {
  value = "${aws_ssm_document.doc.name}"
}

resource "aws_ssm_document" "doc" {
  name          = "${var.name}"
  document_type = "${var.document_type}"
  content       = "${var.content}"
}
