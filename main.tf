module "to-do-app-cluster" {
  source = "./module-eks"
}

resource "aws_s3_bucket" "infra-todo-s3" {
  bucket = "infra-todo"
}

module "my-vpc" {
  source = "./module-vpc"
}