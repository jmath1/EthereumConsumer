output "node_ip" {
  value = aws_instance.ethereum_node.public_ip
}

output "consumer_stream_name" {
  value = aws_kinesis_stream.ethereum_transactions.name
}