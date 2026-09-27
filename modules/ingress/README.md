# Legacy ingress-nginx submodule

Install ingress-nginx in an existing Kubernetes cluster. The caller supplies configured `kubernetes` and `helm` providers. Defaults allow a minimal configuration; controller settings, custom error pages, and metrics can be overridden independently.

[Upstream ingress-nginx retired in March 2026](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/). This integration is retained for existing deployments.

```hcl
module "ingress" {
  source = "git::https://github.com/deepai-cloud/terraform-digitalocean-kubernetes.git//modules/ingress?ref=v1.3.0" # x-release-please-version

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  metrics = { enabled = true }
}
```

The Helm release references the managed error-page ConfigMap so that the ConfigMap is created before pods try to mount it.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| helm | ~> 2.17 |
| kubernetes | ~> 2.38 |

## Providers

| Name | Version |
|------|---------|
| helm | ~> 2.17 |
| kubernetes | ~> 2.38 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.ingress_nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map.custom_error_pages](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_namespace.ingress_nginx](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service.ingress_nginx](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| custom_error_pages | Custom error pages configuration | <pre>object({<br/>    enabled = bool<br/>    pages   = optional(map(string), {})<br/>  })</pre> | <pre>{<br/>  "enabled": false,<br/>  "pages": {}<br/>}</pre> | no |
| ingress_controller_config | NGINX Ingress Controller configuration | <pre>object({<br/>    # Proxy settings<br/>    proxy_body_size       = optional(string, "100m")<br/>    proxy_read_timeout    = optional(string, "60")<br/>    proxy_send_timeout    = optional(string, "60")<br/>    proxy_connect_timeout = optional(string, "60")<br/>    proxy_buffer_size     = optional(string, "16k")<br/>    proxy_buffers_number  = optional(string, "4")<br/><br/>    # Client settings<br/>    client_max_body_size    = optional(string, "100m")<br/>    client_body_timeout     = optional(string, "60")<br/>    client_header_timeout   = optional(string, "60")<br/>    client_body_buffer_size = optional(string, "16k")<br/><br/>    # Keep-alive settings<br/>    keep_alive                     = optional(string, "75")<br/>    keep_alive_requests            = optional(string, "1000")<br/>    upstream_keepalive_timeout     = optional(string, "60")<br/>    upstream_keepalive_connections = optional(string, "256")<br/><br/>    # Security settings<br/>    allow_snippet_annotations = optional(bool, false)<br/>    annotations_risk_level    = optional(string, "High")<br/><br/>    # Custom error pages<br/>    custom_http_errors = optional(string, "")<br/><br/>    # Additional config entries<br/>    additional_config = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| ingress_nginx_version | Version of the ingress-nginx Helm chart | `string` | `"4.14.1"` | no |
| metrics | Prometheus metrics configuration for ingress controller | <pre>object({<br/>    enabled = bool<br/>    port    = optional(number, 10254)<br/>  })</pre> | <pre>{<br/>  "enabled": false,<br/>  "port": 10254<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| external_ip | External IP address of the NGINX Ingress Controller LoadBalancer |
| load_balancer_hostname | Hostname of the NGINX Ingress Controller LoadBalancer |
| namespace | Namespace where ingress-nginx is installed |
<!-- END_TF_DOCS -->
