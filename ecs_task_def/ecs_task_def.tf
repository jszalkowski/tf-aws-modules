variable "family" {}
variable "container_definitions" {}

variable "network_mode" {
  default = "bridge"
}

output "task_def_family" {
  value = "${aws_ecs_task_definition.task_definition.family}"
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${var.family}"
  container_definitions = "${var.container_definitions}"
  network_mode          = "${var.network_mode}"
}
