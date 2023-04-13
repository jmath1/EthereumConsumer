resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc._.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_subnet" "private" {
  cidr_block = cidrsubnet(aws_vpc._.cidr_block, 4, 1)
  vpc_id     = aws_vpc._.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc._.id
  cidr_block              = cidrsubnet(aws_vpc._.cidr_block, 4, 2)
  map_public_ip_on_launch = true
}

resource "aws_vpc" "_" {
  cidr_block = var.vpc_cidr
}