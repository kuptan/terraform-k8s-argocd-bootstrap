target_cluster_name = "eks-dev-vp-ops"

managed_clusters_names = ["eks-dev-vp-sanity-a"]

argocd_git_repo_url = "git@github.com:reynencourt/vendor-pipeline-argocd.git"

argocd_additional_applications = [{
  name = "root"
  namespace = "argo-system"
  project = "vendor-pipeline"
  source = {
    repoURL = "git@github.com:reynencourt/vendor-pipeline-argocd.git"
    targetRevision = "master"
    path = "root"
    directory = {
      recurse = false
    }
  }
  destination = {
    server = "https://kubernetes.default.svc"
    namespace = "default"
  }
  syncPolicy = {
    automated = {
      prune = false
      selfHeal = false
    }
  }
}]

argocd_additional_projects = [{
  name = "vendor-pipeline"
  description = "project to handle all vendor pipeline infrastructure"
  namespace = "argo-system"
  sourceRepos = ["*"]
  destinations = [{
    namespace = "*"
    server = "*"
  }]
  clusterResourceWhitelist = [{
    group = "*"
    kind = "*"
  }]
  namespaceResourceWhitelist = [{
    group = "*"
    kind = "*"
  }]
}]