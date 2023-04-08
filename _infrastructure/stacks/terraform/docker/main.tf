resource "aws_ecr_repository" "eth_consumer" {
  name = var.ecr_repo_name
}