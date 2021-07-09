data "aws_eks_cluster" "target" {
  name = var.target_cluster_name
}

data "aws_eks_cluster_auth" "target" {
  name = var.target_cluster_name
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

resource "kubernetes_namespace" "argo" {
  metadata {
    name   = var.namespace
    labels = var.namespace_labels
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}
