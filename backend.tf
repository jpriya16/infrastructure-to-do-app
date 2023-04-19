terraform {
  backend "s3" {
    bucket = "infra-todo"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}