terraform {
  required_version = "= 1.0.5"
}

# PROVIDER

provider "kubernetes" {
  alias          = "cluster_1"
  config_path    = "~/.kube/config"
  config_context = var.kubernetes["cluster_1"].config_context
}

# MODULE

module "cluster_1" {
  source                    = "./modules/bootstrap"
  github_owner              = var.github_owner
  github_repository_branch  = var.github_repository_branch
  github_repository_name    = var.github_repository_name
  kubernetes_cluster_name   = var.kubernetes["cluster_1"].cluster_name
  providers = {
    kubernetes = kubernetes.cluster_1
  }
}
