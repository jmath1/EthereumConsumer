resource "aws_cloudwatch_log_group" "_" {
  name = "/ecs/eth-consumer"
}

resource "aws_cloudwatch_log_stream" "eth_consumer" {
  name           = "container"
  log_group_name = aws_cloudwatch_log_group._.name
}