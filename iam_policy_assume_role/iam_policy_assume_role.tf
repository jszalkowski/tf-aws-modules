variable "policy_name" {}

variable "assume_role" {}

variable "account_number" {}

output "policy_arn" {
    value = "${module.iam_policy_assume_role.policy_arn}"
}

module "iam_policy_assume_role" {
    policy_name        = "${var.policy_name}"
    policy_description = "Policy to allow users to assume ${var.assume_role}"
    policy             = <<EOF
{
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:iam::${var.account_number}:role/${var.assume_role}"
            ]
        }
    ],
    "Version": "2012-10-17"
}
EOF
    source             = "../iam_policy"
}
