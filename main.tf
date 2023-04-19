

module "my-vpc" {
  source = "./module-vpc"
}

module "to-do-app-cluster" {
  source = "./module-eks"
}



