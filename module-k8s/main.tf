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
  name = "to-do-app-cluster"
}

data "aws_eks_cluster_auth" "to-do-app-cluster" {
  name = "to-do-app-cluster"
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

