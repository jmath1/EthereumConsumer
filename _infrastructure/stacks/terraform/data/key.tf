resource "aws_key_pair" "node_key" {
  key_name   = "node_key"
  public_key = local.public_key
}
