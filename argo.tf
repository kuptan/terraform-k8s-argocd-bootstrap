resource "helm_release" "this" {
  name      = "argo-cd"
  namespace = var.create_namespace ? kubernetes_namespace.this.0.metadata.0.name : var.namespace

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  values = var.additional_chart_value_files

  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt(random_password.this.result)
    type  = "string"
  }

  set {
    name  = "configs.secret.argocdServerAdminPasswordMtime"
    value = "2020-01-01T10:11:12Z" //date "2020-01-01T10:11:12Z" , https://github.com/argoproj/argo-helm/issues/347#issuecomment-698871506
    type  = "string"
  }

  dynamic "set" {
    for_each = var.chart_values_overrides

    content {
      name  = set.key
      value = set.value
    }
  }
}