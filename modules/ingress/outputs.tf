output "external_ip" {
  description = "External IP address of the NGINX Ingress Controller LoadBalancer"
  value       = try(data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip, null)
}

output "load_balancer_hostname" {
  description = "Hostname of the NGINX Ingress Controller LoadBalancer"
  value       = try(data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname, null)
}

output "namespace" {
  description = "Namespace where ingress-nginx is installed"
  value       = kubernetes_namespace.ingress_nginx.metadata[0].name
}
