resource "kubernetes_namespace" "argo" {
  metadata {
    name   = var.namespace
    labels = var.namespace_labels
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}
