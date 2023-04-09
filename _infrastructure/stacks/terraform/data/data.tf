data "aws_region" "current" {}

data "aws_availability_zones" "current" {
  state = "available"
}

data "http" "my_ip" {
  url = "https://api.ipify.org?format=json"
}

data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}