resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "node_key" {
  key_name   = "node_key"
  public_key = tls_private_key.private_key.public_key_openssh
}
