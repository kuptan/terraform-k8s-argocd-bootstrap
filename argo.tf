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
      additionalApplications = var.additional_applications
      additionalProjects     = var.additional_projects
    }
  }

  gitSSHSecretKey = "sshPrivateKey"

  valueFiles = concat([
    yamlencode(local.cluster_credentials),
    yamlencode(local.argocd_config)
  ], var.additional_chart_value_files)

  main_git_repo = var.git_repo_url != "" ? [{
    type = "git"
    url  = var.git_repo_url
    sshPrivateKeySecret = {
      name = kubernetes_secret.git.0.metadata.0.name
      key  = local.gitSSHSecretKey
    }
  }] : []

  additional_repositories = [
    for r in var.private_helm_repositories : {
      type = "helm"
      name = r.name
      url  = r.url
      usernameSecret = {
        name = r.secret_name
        key  = "username"
      }
      passwordSecret = {
        name = r.secret_name
        key  = "password"
      }
    }
  ]

  repositories_config = <<cfg
server:
  config:
    repositories: |
      ${indent(6, yamlencode(concat(local.main_git_repo, local.additional_repositories)))}
  cfg
}

resource "tls_private_key" "git" {
  count = var.git_ssh_auto_generate_keys ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "kubernetes_secret" "git" {
  count = var.git_repo_url != "" ? 1 : 0

  metadata {
    name      = "argocd-git-ssh-credentials"
    namespace = var.create_namespace ? kubernetes_namespace.this.0.metadata.0.name : var.namespace
    labels    = {}
  }

  data = {
    "${local.gitSSHSecretKey}" = var.git_ssh_auto_generate_keys ? tls_private_key.git.0.private_key_pem : var.git_ssh_private_key
  }

  type = "Opaque"
}

resource "helm_release" "this" {
  name      = "argo-cd"
  namespace = var.create_namespace ? kubernetes_namespace.this.0.metadata.0.name : var.namespace

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  values = concat([local.repositories_config], local.valueFiles)

  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt(random_password.this.result)
    type  = "string"
  }

  set {
    name  = "configs.secret.argocdServerAdminPasswordMtime"
    value = "2020-01-01T10:11:12Z" //date "2020-01-01T10:11:12Z" , https://github.com/argoproj/argo-helm/issues/347#issuecomment-698871506
    type  = "string"
  }

  dynamic "set" {
    for_each = var.chart_values_overrides

    content {
      name  = set.key
      value = set.value
    }
  }
}