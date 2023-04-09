data "terraform_remote_state" "persistence" {
  backend = "s3"
  config = {
    bucket = var.STATE_BUCKET
    key    = "persistence.tfstate"
    region = data.aws_region.current.name
  }
}