variable "STATE_BUCKET" {
  type = string
}

variable "instance_type" {
  default = "t3.small"
}

variable "public_key_file" {
  default = "~/.ssh/id_rsa.pub"
}