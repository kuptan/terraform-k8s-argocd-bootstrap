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