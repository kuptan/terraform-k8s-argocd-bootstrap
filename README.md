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

######### 
### AWS EKS remote cluster credentials
#########
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
  source = "kube-champ/argocd-bootstrap/k8s"

  remote_clusters = [
    for c in var.remote_clusters : {
      name       = c.name
      namespaces = c.namespaces
      host : data.aws_eks_cluster.remote[c.name].endpoint
      caData : data.aws_eks_cluster.remote[c.name].certificate_authority.0.data
      token : data.aws_eks_cluster_auth.remote[c.name].token
    }
  ]

  git_repo_url = "git@github.com:reynencourt/vendor-pipeline-argocd.git"

  additional_applications = [{
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

  additional_projects = [{
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
```

Check the [examples folder](https://github.com/kube-champ/terraform-k8s-argocd-bootstrap/tree/master/examples) for more examples 

**Note**: Once your cluster is successfully bootstrapped, you'll need to get the git SSH public key and add it as a deploy key in your git repo. The public key is exposed as an output from the module under the name `git_public_key`.

### Overrides Charts Values
```terraform
module "argocd-bootstrap" {
  source = "kube-champ/argocd-bootstrap/k8s"
  ...

  additional_chart_value_files = [file("path/to/values/file.yaml")]

  chart_values_overrides = {
    "controller.name" = "custom-controller-name"
  }
}
```

### BYOK (Bring Your Own Keys)
```terraform
module "argocd-bootstrap" {
  source = "kube-champ/argocd-bootstrap/k8s"
  ...

  git_ssh_auto_generate_keys = false
  git_ssh_private_key = "YOUR_PRIVATE_KEY"
}
```
## Module Info
See the module info here [here](./TERRAFORM.md) or view it on the [Terraform Registry](https://registry.terraform.io/modules/kube-champ/argocd-bootstrap/k8s/latest)

## Contributing
See contributing docs [here](./docs/CONTRIBUTING.md)
