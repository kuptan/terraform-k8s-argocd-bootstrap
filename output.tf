output "namespace" {
  value = var.create_namespace ? kubernetes_namespace.this.0.metadata.0.name : var.namespace
}

output "admin_password" {
  sensitive = true
  value     = random_password.this.result
}