# Terraform K8s ArgoCD Bootstrap
A terraform module that will bootstrap a Kubernetes cluster with ArgoCD and Sealed Secrets.

## Limitations
1. The module only support AWS EKS clusters

## Usage
Below are few examples on how to use this module

```terraform
module "argocd-bootstrap" {
  source  = "kube-champ/argocd-bootstrap/k8s"

  target_cluster_name = "cluster-ops"
  managed_clusters_names = ["cluster-a", "cluster-b]
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
}

```

Once your cluster is successfully bootstrapped, you'll need to get the git SSH public key and add it as a deploy key in your git repo. The public key is outputed from the module under  `argocd_git_public_key`.


## Module Info
See the module info here [here](./TERRAFORM.md) or view it on the [Terraform Registry](https://registry.terraform.io/modules/kube-champ/argocd-bootstrap/k8s/latest)

## Contributing
See contributing docs [here](./docs/CONTRIBUTING.md)
