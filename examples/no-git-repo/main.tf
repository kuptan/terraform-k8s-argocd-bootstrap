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

module "argocd-bootstrap" {
  # source = "kube-champ/argocd-bootstrap/k8s"
  source = "../../"

  remote_clusters = []

  additional_applications = []
  additional_projects     = []
}