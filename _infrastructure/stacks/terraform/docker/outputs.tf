output "ecr_uri" {
  value = aws_ecr_repository.eth_consumer.repository_url
}