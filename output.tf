output "namespace" {
  value = var.create_namespace ? kubernetes_namespace.this.0.metadata.0.name : var.namespace
}

output "git_public_key" {
  value = var.git_ssh_auto_generate_keys ? tls_private_key.git.0.public_key_openssh : "CUSTOM_KEY_USED"
}

output "git_private_key" {
  sensitive = true
  value     = var.git_ssh_auto_generate_keys ? tls_private_key.git.0.private_key_pem : "CUSTOM_KEY_USED"
}

output "admin_password" {
  sensitive = true
  value     = random_password.this.result
}