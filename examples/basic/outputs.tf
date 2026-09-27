output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = module.kubernetes.cluster_id
}

output "kubeconfig" {
  description = "Kubeconfig for kubectl access"
  value       = module.kubernetes.kubeconfig
  sensitive   = true
}
