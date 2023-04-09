resource "aws_kinesis_stream" "ethereum_transactions" {
  name             = "ethereum-consumer-transactions"
  shard_count      = 1
  retention_period = 24
}

resource "aws_iam_role" "kinesis_firehose_role" {
  name = "kinesis-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kinesis_firehose_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.kinesis_firehose_role.name
}

resource "aws_kinesis_firehose_delivery_stream" "ethereum_transactions_to_s3" {
  name        = "ethereum-transactions-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    bucket_arn         = aws_s3_bucket.ethereum_transactions.arn
    buffer_size        = 5
    buffer_interval    = 300
    compression_format = "GZIP"
    role_arn           = aws_iam_role.kinesis_firehose_role.arn
  }

  depends_on = [
    aws_s3_bucket.ethereum_transactions
  ]
}

resource "aws_s3_bucket" "ethereum_transactions" {
  bucket = "ethereum-transactions"
}