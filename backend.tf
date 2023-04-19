terraform {
  backend "s3" {
    bucket = "infra-todo-application"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}