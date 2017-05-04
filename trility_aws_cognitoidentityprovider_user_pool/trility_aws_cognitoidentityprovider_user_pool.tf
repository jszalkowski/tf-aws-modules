variable "user_pool_name" {}

variable "minimum_length" {
  default = "8"
}

variable "require_lowercase" {
  default = "true"
}

variable "require_uppercase" {
  default = "false"
}

variable "require_numbers" {
  default = "true"
}

variable "require_symbols" {
  default = "false"
}

output "user_pool_id" {
  value = "${trility_aws_cognitoidentityprovider_user_pool.user_pool.id}"
}

resource "trility_aws_cognitoidentityprovider_user_pool" "user_pool" {
  poolname = "${var.user_pool_name}"

  policies {
    password_policy {
      minimum_length    = "${var.minimum_length}"
      require_lowercase = "${var.require_lowercase}"
      require_uppercase = "${var.require_uppercase}"
      require_numbers   = "${var.require_numbers}"
      require_symbols   = "${var.require_symbols}"
    }
  }
}
