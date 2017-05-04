variable "ecs_service" {}
variable "ecs_cluster" {}
variable "task_definition" {}

variable "desired_count" {
  default = 3
}

variable "service_role" {}
variable "ecs_elb" {}
variable "container_name" {}
variable "container_port" {}

resource "aws_ecs_service" "service" {
  name            = "${var.ecs_service}"
  cluster         = "${var.ecs_cluster}"
  task_definition = "${var.task_definition}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${var.service_role}"

  load_balancer {
    elb_name       = "${var.ecs_elb}"
    container_name = "${var.container_name}"
    container_port = "${var.container_port}"
  }
}
