variable "git_repo_url" {
  description = "The ArgoCD git config"
  type        = string

  default = ""
}

variable "remote_clusters" {
  description = "A list of remote clusters that will be managed by ArgoCD"
  type = list(object({
    name : string
    namespaces : list(string)
    host : string
    caData : string
    token : string
  }))

  default = []
}

variable "create_namespace" {
  description = "Indicates whether to create a Kubernetes namespace or not"
  type        = bool

  default = true
}

variable "namespace" {
  description = "The namespace name that will be created for argo and sealed secret"
  type        = string

  default = "argo-system"
}

variable "namespace_labels" {
  description = "labels to be added to the namespace"
  type        = map(string)

  default = {}
}

variable "chart_version" {
  description = "The ArgoCD chart version"
  type        = string

  default = "3.7.1"
}

variable "additional_applications" {
  description = "Additional applications to be added to ArgoCD"
  type        = list(any)

  default = []
}

variable "additional_projects" {
  description = "Additional projeccts to be added to ArgoCD"
  type        = list(any)

  default = []
}

variable "private_helm_repositories" {
  description = "Private helm repositories to be added. The secret needs to have 'username' and 'password'"
  type = list(object({
    name : string
    url : string
    secret_name : string
  }))

  default = []
}

variable "additional_chart_value_files" {
  description = "A list of values.yaml files to be added to the argo installation."
  type        = list(string)

  default = []
}

variable "chart_values_overrides" {
  description = "A map of key/value to override the argocdc chart values. The key must be the path/name of the chart value, e.g: `path.to.chart.key`"
  type        = map(string)

  default = {}
}

variable "git_ssh_auto_generate_keys" {
  description = "A flag to auto generate keys for git SSH"
  type        = bool

  default = true
}

variable "git_ssh_private_key" {
  description = "The keys config for argocd git repo"
  sensitive   = true
  type        = string

  default = ""
}