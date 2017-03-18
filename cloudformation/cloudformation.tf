variable "stack_name" {}
variable "template_body" {}

resource "aws_cloudformation_stack" "stack" {
  name          = "${var.stack_name}"
  template_body = "${var.template_body}"
}
