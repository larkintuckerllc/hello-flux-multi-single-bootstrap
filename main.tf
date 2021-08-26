terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "= 1.11.3"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "= 2.4.1"
    }
  }
  required_version = "= 1.0.5"
}

# PROVIDER

provider "kubectl" {
  alias          = "cluster_1"
  config_path    = "~/.kube/config"
  config_context = var.kubernetes["cluster_1"].config_context
}

provider "kubectl" {
  alias          = "cluster_2"
  config_path    = "~/.kube/config"
  config_context = var.kubernetes["cluster_2"].config_context
}

provider "kubernetes" {
  alias          = "cluster_1"
  config_path    = "~/.kube/config"
  config_context = var.kubernetes["cluster_1"].config_context
}

provider "kubernetes" {
  alias          = "cluster_2"
  config_path    = "~/.kube/config"
  config_context = var.kubernetes["cluster_2"].config_context
}

# MODULE

module "cluster_1" {
  source                    = "./modules/bootstrap"
  github_owner              = var.github_owner
  github_repository_branch  = var.github_repository_branch
  github_repository_name    = var.github_repository_name
  kubernetes_cluster_name   = var.kubernetes["cluster_1"].cluster_name
  providers = {
    kubectl    = kubectl.cluster_1
    kubernetes = kubernetes.cluster_1
  }
}

module "cluster_2" {
  source                    = "./modules/bootstrap"
  github_owner              = var.github_owner
  github_repository_branch  = var.github_repository_branch
  github_repository_name    = var.github_repository_name
  kubernetes_cluster_name   = var.kubernetes["cluster_2"].cluster_name
  providers = {
    kubectl    = kubectl.cluster_2
    kubernetes = kubernetes.cluster_2
  }
}
