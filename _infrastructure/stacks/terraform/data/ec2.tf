
resource "aws_instance" "ethereum_node" {
  ami               = data.aws_ami.latest.id
  instance_type     = var.instance_type
  key_name          = aws_key_pair.node_key.key_name
  security_groups   = [aws_security_group.ethereum.name]
  availability_zone = element(data.aws_availability_zones.current.names, 0)
  depends_on = [
    aws_key_pair.node_key
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = 10
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo docker run -d --name ethereum-node ethereum/client-go:stable --syncmode "full" --cache 8192
              EOF
}


resource "aws_volume_attachment" "ethereum_data_attachment" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.ethereum_node.id
  volume_id   = data.terraform_remote_state.persistence.outputs.ebs_volume_id
}

resource "aws_security_group" "ethereum" {
  name_prefix = "ethereum-"
  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
