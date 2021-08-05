provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

resource "kubernetes_secret" "helm_credentials" {
  metadata {
    name      = "repo-private-test"
    namespace = "argo-system"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    username = "username-123"
    password = "password!@#51"
  }

  type = "Opaque"
}

module "argocd-bootstrap" {
  # source = "kube-champ/argocd-bootstrap/k8s"
  source = "../../"

  remote_clusters = []

  additional_applications = []
  additional_projects     = []

  git_repo_url = "git@github.com:reynencourt/vendor-pipeline-argocd.git"

  private_helm_repositories = [{
    name        = "test-private-repo"
    url         = "https://chart-repo.domain.com/helm-charts"
    secret_name = kubernetes_secret.helm_credentials.metadata.0.name
  }]
}