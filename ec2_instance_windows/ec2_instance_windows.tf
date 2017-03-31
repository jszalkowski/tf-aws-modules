variable "account_name" {}

variable "ami_id" {}

variable "aws_keypair" {}

variable "aws_region" {}

variable "chef_policy" {}

variable "chef_policy_group" {}

variable "chef_server_url" {}

variable "instance_name" {}

variable "instance_profile" {}

variable "instance_type" {
  default = "t2.medium"
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

output "instance_id" {
  value = "${aws_instance.ec2_instance.id}"
}

resource "aws_instance" "ec2_instance" {
  ami                     = "${var.ami_id}"
  disable_api_termination = "${var.termination_protection}"
  key_name                = "${var.aws_keypair}"
  iam_instance_profile    = "${var.instance_profile}"
  instance_type           = "${var.instance_type}"
  subnet_id               = "${var.subnet}"

  tags {
    Name      = "${var.instance_name}"
    Snapshots = "${var.snapshots}"
  }

  user_data = <<EOF
<powershell>
Invoke-Webrequest https://packages.chef.io/files/stable/chef/12.19.36/windows/2012r2/chef-client-12.19.36-1-x64.msi -Outfile C:\Windows\Temp\chef-client-12.19.36-1-x64.msi

& msiexec /qn /i C:\Windows\Temp\chef-client-12.19.36-1-x64.msi ADDLOCAL="ChefClientFeature,ChefSchTaskFeature,ChefPSModuleFeature"

Read-S3Object -Bucketname trility-infra -Key trility-validation.pem -File C:\chef\trility-validation.pem
Read-S3Object -Bucketname trility-infra -Key AWS_OpsWorks_Intermediate_CA_for_us-west-2_region.crt -File C:\chef\trusted_certs\AWS_OpsWorks_Intermediate_CA_for_us-west-2_region.crt
Read-S3Object -Bucketname trility-infra -Key AWS_OpsWorks_Root_CA.crt -File C:\chef\trusted_certs\AWS_OpsWorks_Root_CA.crt
Read-S3Object -Bucketname trility-infra -Key opsworks-cm-ca-2016-root.pem -File C:\chef\trusted_certs\opsworks-cm-ca-2016-root.pem

Add-Content C:\chef\client.rb "chef_server_url '${var.chef_server_url}/organizations/default'"
Add-Content C:\chef\client.rb "trusted_certs_dir 'C:/chef/trusted_certs'"
Add-Content C:\chef\client.rb "node_name '${var.account_name}_${var.instance_name}'"
Add-Content C:\chef\client.rb "validation_key 'C:\chef\${var.account_name}-validation.pem'"
Add-Content C:\chef\client.rb "validation_client_name '${var.account_name}-validation'"

& C:\opscode\chef\bin\chef-client.bat
</powershell>
EOF

  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
}
