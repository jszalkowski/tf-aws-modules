variable "domain_name" {}
variable "ad_password" {}

variable "subnets" {
  type = "list"
}

variable "vpc" {}

module "ad" {
  name     = "${var.domain_name}"
  password = "${var.ad_password}"
  subnets  = ["${var.subnets}"]
  vpc      = "${var.vpc}"
  source   = "github.com/Trility/tf-aws-modules//directory_service"
}

module "iam_role_windows" {
  role_name = "windows"
  source    = "github.com/Trility/tf-aws-modules//iam_role"
}

module "iam_role_policy_attachment_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role_name  = "${module.iam_role_windows.role_name}"
  source     = "github.com/Trility/tf-aws-modules//iam_role_policy_attachment"
}

module "iam_instance_profile_windows" {
  profile_name = "windows"
  roles        = ["${module.iam_role_windows.role_name}"]
  source       = "github.com/Trility/tf-aws-modules//iam_instance_profile"
}

module "ssm_document_join_domain" {
  name          = "join_${var.domain_name}"
  document_type = "Command"

  content = <<DOC
{
    "schemaVersion": "1.0",
    "description": "Sample configuration to join an instance to a domain",
    "runtimeConfig": {
        "aws:domainJoin": {
            "properties": {
                "directoryId": "${module.ad.id}",
                "directoryName": "${var.domain_name}",
                "dnsIpAddresses": [
                   "${module.ad.dns_ip_addresses}"
                ]
            }
        }
    }
}
DOC

  source = "github.com/Trility/tf-aws-modules//ssm_document"
}