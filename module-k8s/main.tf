terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
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
#provider "kubernetes" {
#  host = var.host
#  client_certificate     = var.client_certificate
#  client_key             = var.client_key
#  cluster_ca_certificate = var.cluster_ca_certificate
#}

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
          image = "public.ecr.aws/v9y1c4w4/to-do-app:latest"
          name = "to-do-app"
          port {
            container_port = 80
          }
        }
      }
    }
  }
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
  }
}

