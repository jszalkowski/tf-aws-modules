variable "app_name" {}
variable "ds_policy_name" {}
variable "env_short" {}
variable "graphite_host" {}
variable "iam_instance_profile" {}
variable "ids_server" {}
variable "image_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "launch_config_name" {}
variable "lc_env" {}

variable "security_groups" {
  type = "list"
}

output "launch_configuration" {
  value = "${aws_launch_configuration.launch_config.id}"
}

resource "aws_launch_configuration" "launch_config" {
  associate_public_ip_address = false

  ebs_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    device_name           = "/dev/sdb"
  }

  iam_instance_profile = "${var.iam_instance_profile}"
  image_id             = "${var.image_id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "${var.launch_config_name}-"

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
  }

  security_groups = ["${var.security_groups}"]

  user_data = <<EOF
#!/bin/bash -ex
##PROP-JSON##:{"app_class": "${var.app_name}","dsa_policy_name": "${var.ds_policy_name}","dsa_server": "${var.ids_server}","ecs_cluster": "${var.lc_env}-${var.app_name}","graphite_host": "${var.graphite_host}","jenkins_build": "${var.lc_env}","trility_environment": "${var.env_short}","stack_name": "${var.lc_env}","app_class":"${var.app_name}"}
EOF
}
