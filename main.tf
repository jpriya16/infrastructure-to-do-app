module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_vpn_gateway = true

  map_public_ip_on_launch = true
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = module.vpc.vpc_id
  //   depends_on = [
  //    module.vpc
  //  ]
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

  vpc_id                   = module.vpc.vpc_id
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

}
//module "to-do-app-cluster" {
//  source = "./module-eks"
//  vpc_id = module.my-vpc.vpc_id
//}

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
  default = ""
}

data "aws_eks_cluster" "to-do-app-cluster" {
//  name = "to-do-app-cluster"
  name = module.eks.cluster_name
//  depends_on = [
//    module.eks
//  ]
}

data "aws_eks_cluster_auth" "to-do-app-cluster" {
  name = module.eks.cluster_name
//  depends_on = [
//    module.eks
//  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.to-do-app-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.to-do-app-cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.to-do-app-cluster.token
}

resource "kubernetes_deployment" "to-do-app" {
  metadata {
    name = "to-do-app"
    labels = {
      app = "to-do-app"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "to-do-app"
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge = "10%"
        max_unavailable = "10%"
      }
    }
    template {
      metadata {
        labels = {
          app = "to-do-app"
        }
      }
      spec {
        container {
          image = var.image_id
          name = "to-do-app"
          port {
            container_port = 80
          }
        }
      }
    }
  }
    depends_on = [
      data.aws_eks_cluster.to-do-app-cluster
    ]
}

resource "kubernetes_service" "to-do-app-srv-cluster" {
  metadata {
    name = "to-do-app-srv-cluster"
  }
  spec {
    selector = {
      app = "to-do-app"
    }
    port {
      protocol = "TCP"
      port = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
    depends_on = [
      data.aws_eks_cluster.to-do-app-cluster,
      kubernetes_deployment.to-do-app
    ]
}

resource "kubernetes_service" "to-do-app-lb-srv" {
  metadata {
    name = "to-do-app-lb-srv"
  }
  spec {
    selector = {
      app = "to-do-app"
    }
    port {
      protocol = "TCP"
      port = 80
      target_port = 80
    }
    type = "LoadBalancer"
    load_balancer_source_ranges = [
      "3.7.0.0/16"
    ]
  }
    depends_on = [
      data.aws_eks_cluster.to-do-app-cluster,
      kubernetes_deployment.to-do-app,
      kubernetes_service.to-do-app-srv-cluster
    ]
}

