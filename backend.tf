terraform {
  backend "s3" {
    bucket = "infra-todo-app"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}