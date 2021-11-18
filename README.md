# Terraform K8s ArgoCD Bootstrap
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![GitHub Release](https://img.shields.io/github/release/kube-champ/terraform-k8s-argocd-bootstrap.svg?style=flat)]() [![PR's Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

A terraform module that will bootstrap a Kubernetes cluster with ArgoCD.

## Usage

```terraform
variable "target_cluster_name" {
  description = "The cluster name where the ArgoCD will be installed"
  type        = string

  default = "operation-cluster"
}

variable "remote_clusters" {
  description = "Remote cluster to be managed by ArgoCD"
  type        = list(object({ name : string, namespaces : list(string) }))

  default = [{
    name       = "cluster-a"
    namespaces = ["default", "cert-manager", "monitoring"]
  }]
}

######### 
### AWS EKS target cluster credentials
#########
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

module "argocd-bootstrap" {
  source = "kube-champ/argocd-bootstrap/k8s"
  ...

  chart_version = "3.7.1"
  
  additional_chart_value_files = [file("path/to/values/file.yaml")]

  chart_values_overrides = {
    "controller.name" = "custom-controller-name"
  }
}
```

Check the [examples folder](https://github.com/kube-champ/terraform-k8s-argocd-bootstrap/tree/master/examples) for more examples 

## Module Info
See the module info here [here](./TERRAFORM.md) or view it on the [Terraform Registry](https://registry.terraform.io/modules/kube-champ/argocd-bootstrap/k8s/latest)

## Contributing
See contributing docs [here](./docs/CONTRIBUTING.md)
