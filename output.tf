output "argocd_generated_admin_password" {
  sensitive = true
  value = random_password.argo_admin_password.0.result
}
output "argocd_git_public_key" {
  value = var.argocd_git_ssh_key.auto_generate_keys ? tls_private_key.git.0.public_key_openssh : "CUSTOM_KEY_USED"
}

output "argocd_git_private_key" {
  sensitive = true
  value     = var.argocd_git_ssh_key.auto_generate_keys ? tls_private_key.git.0.private_key_pem : "CUSTOM_KEY_USED"
}

output "sealed_secrets_generated_private_key" {
  sensitive = true
  value     = var.sealed_secrets_key_cert.auto_generate_key_cert ? tls_private_key.sealed_secret_key.0.private_key_pem : "CUSTOM_KEY_USED"
}

output "sealed_secrets_generated_cert" {
  sensitive = true
  value     = var.sealed_secrets_key_cert.auto_generate_key_cert ? tls_self_signed_cert.sealed_secret_cert.0.cert_pem : "CUSTOM_CERT_USED"
}