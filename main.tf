module "my-vpc" {
  source = "./module-vpc"
}

module "to-do-app-cluster" {
  source = "./module-eks"
}

module "to-do-app-k8s" {
  source = "./module-k8s"
}