output "argocd_password" {
  sensitive = true
  value     = module.argocd-bootstrap.admin_password
}