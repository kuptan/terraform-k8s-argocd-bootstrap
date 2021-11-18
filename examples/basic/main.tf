provider "helm" {
  kubernetes {
    config_path    = "~/.kube/minikube"
    config_context = "minikube"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/minikube"
  config_context = "minikube"
}

module "argocd-bootstrap" {
  # source = "kube-champ/argocd-bootstrap/k8s"
  source = "../../"
}