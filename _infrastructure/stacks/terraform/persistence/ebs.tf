resource "aws_ebs_volume" "ethereum_data" {
  size              = var.volume_size
  type              = var.volume_type
  availability_zone = element(data.aws_availability_zones.current.names, 0)
  tags              = { Name = "ethereum-data" }
}