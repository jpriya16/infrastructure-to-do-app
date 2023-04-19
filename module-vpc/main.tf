module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_vpn_gateway = true

  map_public_ip_on_launch = true
}