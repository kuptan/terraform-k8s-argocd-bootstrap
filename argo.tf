locals {
  cluster_credentials = {
    configs = {
      clusterCredentials = [
        for c in var.managed_clusters_names : {
          name       = c
          server     = data.aws_eks_cluster.creds[c].endpoint
          namespaces = "default,argo-system"
          config = {
            bearerToken = data.aws_eks_cluster_auth.creds[c].token
            tlsClientConfig = {
              insecure = false
              caData   = data.aws_eks_cluster.creds[c].certificate_authority.0.data
            }
          }
        }
      ]
    }
  }

  argocd_config = {
    server = {
      additionalApplications = var.argocd_additional_applications
      additionalProjects     = var.argocd_additional_projects
    }
  }

  gitSSHSecretKey = "sshPrivateKey"
}

data "aws_eks_cluster" "creds" {
  for_each = toset(var.managed_clusters_names)

  name = each.value
}

data "aws_eks_cluster_auth" "creds" {
  for_each = toset(var.managed_clusters_names)

  name = each.value
}

data "template_file" "git" {
  template = file("${path.module}/templates/git-config.tmpl")
  vars = {
    GIT_URL     = var.argocd_git_repo_url
    SECRET_NAME = kubernetes_secret.git.metadata.0.name
    SECRET_KEY  = local.gitSSHSecretKey
  }
}

resource "tls_private_key" "git" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "kubernetes_secret" "git" {
  metadata {
    name      = "argocd-git-ssh-credentials"
    namespace = kubernetes_namespace.argo.metadata.0.name
    labels    = {}
  }

  data = {
    "${local.gitSSHSecretKey}" = tls_private_key.git.private_key_pem
  }

  type = "Opaque"
}

resource "helm_release" "argo" {
  name      = "argo-cd"
  namespace = kubernetes_namespace.argo.metadata.0.name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  values = [
    yamlencode(local.cluster_credentials),
    yamlencode(local.argocd_config),
    data.template_file.git.rendered
  ]

  set {
    name  = "global.image.tag"
    value = var.argocd_image_tag
  }
}