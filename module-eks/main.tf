data "aws_vpc" "cluster-vpc" {
  filter {
    name = "tag:Name"
    values = ["my-vpc"]
  }
  depends_on = [
    module.vpc
  ]
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = data.aws_vpc.cluster-vpc.id
   depends_on = [
    module.vpc
  ]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "to-do-app-cluster"
  cluster_version = "1.24"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = data.aws_vpc.cluster-vpc.id
  subnet_ids               = data.aws_subnet_ids.public_subnets.ids

  eks_managed_node_group_defaults = {
    instance_types = ["t3.micro"]
  }

  eks_managed_node_groups = {
    green = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.micro"]
      capacity_type  = "ON_DEMAND"
    }
  }
  tags = {
    cluster_name   = "to-do-app-cluster"
    terraform = "true"
  }

  depends_on = [
    data.aws_vpc.cluster-vpc
  ]
}