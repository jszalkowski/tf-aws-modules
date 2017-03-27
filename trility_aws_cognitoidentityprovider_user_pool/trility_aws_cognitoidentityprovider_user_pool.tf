variable "user_pool_name" {}

output "user_pool_id" {
  value = "${trility_aws_cognitoidentityprovider_user_pool.user_pool.id}"
}

resource "trility_aws_cognitoidentityprovider_user_pool" "user_pool" {
  poolname = "${var.user_pool_name}"
}
