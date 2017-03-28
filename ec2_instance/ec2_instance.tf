variable "account_name" {}

variable "ami_id" {}

variable "aws_keypair" {}

variable "aws_region" {}

variable "chef_policy" {}

variable "chef_policy_group" {}

variable "chef_server" {}

variable "chef_server_url" {}

variable "ebs_root_size" {
  default = 50
}

variable "instance_name" {}

variable "instance_profile" {}

variable "instance_type" {}

variable "lvm_opt_size" {
  default = 20
}

variable "lvm_snapshot_id" {}

variable "lvm_var_size" {
  default = 20
}

variable "lvm_varlog_size" {
  default = 20
}

variable "lvm_varlogaudit_size" {
  default = 5
}

variable "lvm_home_size" {
  default = 10
}

variable "lvm_tmp_size" {
  default = 5
}

variable "snapshots" {
  default = "no"
}

variable "subnet" {}

variable "termination_protection" {
  default = "false"
}

variable "vpc_security_group_ids" {
  type = "list"
}

resource "aws_instance" "ec2_instance" {
  ami                     = "${var.ami_id}"
  disable_api_termination = "${var.termination_protection}"

  root_block_device {
    delete_on_termination = true
    volume_size           = "${var.ebs_root_size}"
    volume_type           = "gp2"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdb"
    snapshot_id           = "${var.lvm_snapshot_id}"
    volume_size           = "${(var.lvm_opt_size) + (var.lvm_var_size) + (var.lvm_varlog_size) + (var.lvm_varlogaudit_size) + (var.lvm_home_size) + (var.lvm_tmp_size) + 20}"
    volume_type           = "gp2"
  }

  key_name             = "${var.aws_keypair}"
  iam_instance_profile = "${var.instance_profile}"
  instance_type        = "${var.instance_type}"
  subnet_id            = "${var.subnet}"

  tags {
    Name      = "${var.instance_name}"
    Snapshots = "${var.snapshots}"
  }

  user_data = <<EOF
#!/bin/bash -ex
echo "/sbin/pvresize /dev/xvdb" >> /var/lib/cloud/instance/scripts/lvmresize
echo "lvextend -L ${var.lvm_opt_size}G /dev/vgpool/opt" >> /var/lib/cloud/instance/scripts/lvmresize
echo "resize2fs /dev/vgpool/opt" >> /var/lib/cloud/instance/scripts/lvmresize
echo "lvextend -L ${var.lvm_var_size}G /dev/vgpool/var" >> /var/lib/cloud/instance/scripts/lvmresize
echo "resize2fs /dev/vgpool/var" >> /var/lib/cloud/instance/scripts/lvmresize
echo "lvextend -L ${var.lvm_varlog_size}G /dev/vgpool/varlog" >> /var/lib/cloud/instance/scripts/lvmresize
echo "resize2fs /dev/vgpool/varlog" >> /var/lib/cloud/instance/scripts/lvmresize
echo "lvextend -L ${var.lvm_varlogaudit_size}G /dev/vgpool/varlogaudit" >> /var/lib/cloud/instance/scripts/lvmresize
echo "resize2fs /dev/vgpool/varlogaudit" >> /var/lib/cloud/instance/scripts/lvmresize
echo "lvextend -L ${var.lvm_home_size}G /dev/vgpool/home" >> /var/lib/cloud/instance/scripts/lvmresize
echo "resize2fs /dev/vgpool/home" >> /var/lib/cloud/instance/scripts/lvmresize
echo "lvextend -L ${var.lvm_tmp_size}G /dev/vgpool/tmp" >> /var/lib/cloud/instance/scripts/lvmresize
echo "resize2fs /dev/vgpool/tmp" >> /var/lib/cloud/instance/scripts/lvmresize
chmod +x /var/lib/cloud/instance/scripts/lvmresize
/var/lib/cloud/instance/scripts/lvmresize
mkdir /etc/chef
openssl genrsa -out /etc/chef/client.pem 2048
aws opsworkscm associate-node --node-name ${var.account_name}_${var.instance_name} --server-name ${var.chef_server} --engine-attributes "Name=CHEF_ORGANIZATION,Value=default" "Name=CHEF_NODE_PUBLIC_KEY,Value='$(openssl rsa -in /etc/chef/client.pem -pubout)'" --region ${var.aws_region}
mkdir /var/log/chef
mkdir /etc/chef/trusted_certs
aws --region ${var.aws_region} s3 cp s3://${var.account_name}-infra/AWS_OpsWorks_Intermediate_CA_for_us-west-2_region.crt /etc/chef/trusted_certs/AWS_OpsWorks_Intermediate_CA_for_us-west-2_region.crt
aws --region ${var.aws_region} s3 cp s3://${var.account_name}-infra/AWS_OpsWorks_Root_CA.crt /etc/chef/trusted_certs/AWS_OpsWorks_Root_CA.crt
aws --region ${var.aws_region} s3 cp s3://${var.account_name}-infra/ /etc/chef/trusted_certs/opsworks-cm-ca-2016-root.pem
chmod 600 /etc/chef/trusted_certs/*
echo "chef_server_url '${var.chef_server_url}/organizations/default'" >> /etc/chef/client.rb
echo "trusted_certs_dir '/etc/chef/trusted_certs'" >> /etc/chef/client.rb
echo "node_name '${var.account_name}_${var.instance_name}'" >> /etc/chef/client.rb
echo "log_location   STDOUT" >> /etc/chef/client.rb
echo "log_level :info" >> /etc/chef/client.rb
echo "log_location '/var/log/chef/client.log'" >> /etc/chef/client.rb
echo "{\"policy_name\": \"${var.chef_policy}\", \"policy_group\": \"${var.chef_policy_group}\" }" >> /etc/chef/attributes.json
chef-client -j /etc/chef/attributes.json
EOF

  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
}
