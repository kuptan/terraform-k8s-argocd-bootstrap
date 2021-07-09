variable "target_cluster_name" {
  description = "The cluster name where the ArgoCD will be installed"
  type        = string

  default = "eks-dev-vp-ops"
}

variable "remote_clusters" {
  description = "Remote cluster to be managed by ArgoCD"
  type        = list(object({ name : string, namespaces : list(string) }))

  default = [{
    name       = "eks-dev-vp-sanity-a"
    namespaces = ["default", "cert-manager", "monitoring"]
  }]
}