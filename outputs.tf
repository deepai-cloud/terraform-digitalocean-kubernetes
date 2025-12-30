# -----------------------------------------------------------------------------
# Cluster Outputs
# -----------------------------------------------------------------------------

output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.this.name
}

output "cluster_urn" {
  description = "URN of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.this.urn
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes API server"
  value       = digitalocean_kubernetes_cluster.this.endpoint
}

output "cluster_ipv4_address" {
  description = "Public IPv4 address of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.this.ipv4_address
}

output "cluster_status" {
  description = "Status of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.this.status
}

output "cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = digitalocean_kubernetes_cluster.this.version
}

# -----------------------------------------------------------------------------
# Kubeconfig Outputs
# -----------------------------------------------------------------------------

output "kubeconfig" {
  description = "Raw kubeconfig for the cluster"
  value       = digitalocean_kubernetes_cluster.this.kube_config[0].raw_config
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded cluster CA certificate"
  value       = digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "kube_token" {
  description = "Kubernetes authentication token"
  value       = digitalocean_kubernetes_cluster.this.kube_config[0].token
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Node Pool Outputs
# -----------------------------------------------------------------------------

output "default_node_pool_id" {
  description = "ID of the default node pool"
  value       = digitalocean_kubernetes_cluster.this.node_pool[0].id
}

output "additional_node_pool_ids" {
  description = "Map of additional node pool names to their IDs"
  value       = { for k, v in digitalocean_kubernetes_node_pool.additional : k => v.id }
}

# -----------------------------------------------------------------------------
# Ingress Outputs
# -----------------------------------------------------------------------------

output "ingress_external_ip" {
  description = "External IP address of the NGINX Ingress Controller LoadBalancer"
  value       = var.install_nginx_ingress ? module.ingress[0].external_ip : null
}

output "ingress_load_balancer_hostname" {
  description = "Hostname of the NGINX Ingress Controller LoadBalancer"
  value       = var.install_nginx_ingress ? module.ingress[0].load_balancer_hostname : null
}
