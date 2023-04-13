data "terraform_remote_state" "docker" {
  backend = "s3"
  config = {
    bucket = var.STATE_BUCKET
    key    = "docker.tfstate"
    region = data.aws_region.current.name
  }
}

data "terraform_remote_state" "data" {
  backend = "s3"
  config = {
    bucket = var.STATE_BUCKET
    key    = "data.tfstate"
    region = data.aws_region.current.name
  }
}