
terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "= 0.2.2"
    }
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

# DATA

data "flux_install" "this" {
  target_path = "clusters/${var.kubernetes_cluster_name}"
  version     = "v0.16.2"
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.this.content
}

data "flux_sync" "this" {
  branch      = var.github_repository_branch
  target_path = "clusters/${var.kubernetes_cluster_name}"
  url         = "ssh://git@github.com/${var.github_owner}/${var.github_repository_name}"
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.this.content
}

# LOCALS

locals {
  install = [ for v in data.kubectl_file_documents.install.documents : {
    data: yamldecode(v)
    content: v
  } ]
  sync = [ for v in data.kubectl_file_documents.sync.documents : {
    data: yamldecode(v)
    content: v
  } ]
}

# FLUX INSTALL

resource "kubernetes_namespace" "this" {
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
  metadata {
    name = "flux-system"
  }
}

resource "kubectl_manifest" "install" {
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.this]
  yaml_body = each.value
}

# FLUX SYNC

resource "kubectl_manifest" "sync" {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubectl_manifest.install]
  yaml_body = each.value
}
