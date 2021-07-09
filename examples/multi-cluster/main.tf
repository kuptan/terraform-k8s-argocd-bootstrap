data "aws_eks_cluster" "target" {
  name = var.target_cluster_name
}

data "aws_eks_cluster_auth" "target" {
  name = var.target_cluster_name
}

data "aws_eks_cluster" "remote" {
  for_each = { for c in var.remote_clusters : c.name => c }
  name     = each.key
}

data "aws_eks_cluster_auth" "remote" {
  for_each = { for c in var.remote_clusters : c.name => c }
  name     = each.key
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.target.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.target.token
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.target.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.target.token
}

module "argocd-bootstrap" {
  # source = "kube-champ/argocd-bootstrap/k8s"
  source = "../../"

  remote_clusters = [
    for c in var.remote_clusters : {
      name       = c.name
      namespaces = c.namespaces
      host : data.aws_eks_cluster.remote[c.name].endpoint
      caData : data.aws_eks_cluster.remote[c.name].certificate_authority.0.data
      token : data.aws_eks_cluster_auth.remote[c.name].token
    }
  ]

  argocd_git_repo_url = "git@github.com:reynencourt/vendor-pipeline-argocd.git"

  argocd_additional_applications = [{
    name      = "root"
    namespace = "argo-system"
    project   = "vendor-pipeline"
    source = {
      repoURL        = "git@github.com:reynencourt/vendor-pipeline-argocd.git"
      targetRevision = "master"
      path           = "root"
      directory = {
        recurse = false
      }
    }
    destination = {
      server    = "https://kubernetes.default.svc"
      namespace = "default"
    }
    syncPolicy = {
      automated = {
        prune    = false
        selfHeal = false
      }
    }
  }]

  argocd_additional_projects = [{
    name        = "vendor-pipeline"
    description = "project to handle all vendor pipeline infrastructure"
    namespace   = "argo-system"
    sourceRepos = ["*"]
    destinations = [{
      namespace = "*"
      server    = "*"
    }]
    clusterResourceWhitelist = [{
      group = "*"
      kind  = "*"
    }]
    namespaceResourceWhitelist = [{
      group = "*"
      kind  = "*"
    }]
  }]
}