variable "github_owner" {
  type = string
}

variable "github_repository_branch" {
  type = string
}

variable "github_repository_name" {
  type = string
}

variable "kubernetes" {
  type = map(object({
    config_context = string
    cluster_name   = string
  }))
}
