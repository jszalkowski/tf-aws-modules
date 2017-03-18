output "eip_id" {
  value = "${aws_eip.eip.id}"
}

output "eip_public_ip" {
  value = "${aws_eip.eip.public_ip}"
}

resource "aws_eip" "eip" {
  vpc = true
}
