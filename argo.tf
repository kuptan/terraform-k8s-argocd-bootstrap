locals {
  cluster_credentials = {
    configs = {
      clusterCredentials = [
        for c in var.remote_clusters : {
          name       = c.name
          server     = c.host
          namespaces = join(",", c.namespaces)
          config = {
            bearerToken = c.token
            tlsClientConfig = {
              insecure = false
              caData   = c.caData
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
  for_each = { for c in var.remote_clusters : c.name => c }

  name = each.key
}

data "aws_eks_cluster_auth" "creds" {
  for_each = { for c in var.remote_clusters : c.name => c }

  name = each.key
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
  count = var.argocd_git_ssh_auto_generate_keys ? 1 : 0

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
    "${local.gitSSHSecretKey}" = var.argocd_git_ssh_auto_generate_keys ? tls_private_key.git.0.private_key_pem : var.argocd_git_ssh_private_key
  }

  type = "Opaque"
}

resource "helm_release" "argo" {
  name      = "argo-cd"
  namespace = kubernetes_namespace.argo.metadata.0.name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  values = concat([
    yamlencode(local.cluster_credentials),
    yamlencode(local.argocd_config),
    data.template_file.git.rendered
  ], var.argocd_chart_value_files)

  set {
    name  = "global.image.tag"
    value = var.argocd_image_tag
  }
  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt(random_password.argo_admin_password.result)
    type  = "string"
  }
  set {
    name  = "configs.secret.argocdServerAdminPasswordMtime"
    value = "2020-01-01T10:11:12Z" //date "2020-01-01T10:11:12Z" , https://github.com/argoproj/argo-helm/issues/347#issuecomment-698871506
    type  = "string"
  }
  dynamic "set" {
    for_each = var.argocd_chart_values_overrides

    content {
      name  = set.key
      value = set.value
    }
  }
}