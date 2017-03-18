variable "bucket_id" {}
variable "bucket_name" {}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = "${var.bucket_id}"

  policy = <<EOF
{
  "Id": "PutObjPolicy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnEncryptedObjectUploads",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Deny",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      },
      "Principal": "*"
    }
  ]
}
EOF
}
