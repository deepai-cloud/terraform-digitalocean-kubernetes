# OpenTofu DigitalOcean Kubernetes Module

An OpenTofu module for creating and managing DigitalOcean Kubernetes (DOKS) clusters with optional NGINX Ingress Controller.

## Features

- DigitalOcean Kubernetes cluster with auto-scaling node pools
- Optional additional node pools with taints and labels
- NGINX Ingress Controller with customizable configuration
- Custom error pages support
- High availability control plane option
- Configurable maintenance windows

## Usage

### Basic Example

```hcl
module "kubernetes" {
  source = "github.com/your-org/terraform-digitalocean-kubernetes"

  cluster_name = "my-cluster"
  region       = "fra1"

  default_node_pool = {
    size       = "s-4vcpu-8gb"
    min_nodes  = 1
    max_nodes  = 5
    auto_scale = true
  }
}
```

### Complete Example

```hcl
module "kubernetes" {
  source = "github.com/your-org/terraform-digitalocean-kubernetes"

  cluster_name = "production-cluster"
  region       = "fra1"
  ha           = true

  default_node_pool = {
    size       = "s-4vcpu-8gb"
    min_nodes  = 2
    max_nodes  = 10
    auto_scale = true
    labels = {
      "node-type" = "general"
    }
  }

  additional_node_pools = [
    {
      name       = "high-memory"
      size       = "g-8vcpu-32gb"
      min_nodes  = 1
      max_nodes  = 5
      auto_scale = true
      labels = {
        "node-type" = "high-memory"
      }
      taints = [
        {
          key    = "dedicated"
          value  = "high-memory"
          effect = "NoSchedule"
        }
      ]
    }
  ]

  maintenance_policy = {
    start_time = "04:00"
    day        = "sunday"
  }

  # Ingress Configuration
  install_nginx_ingress = true
  ingress_nginx_version = "4.11.3"

  ingress_controller_config = {
    proxy_body_size       = "15g"
    proxy_read_timeout    = "21600"
    proxy_send_timeout    = "21600"
    proxy_connect_timeout = "60"
    client_max_body_size  = "15g"
    client_body_timeout   = "21600"

    allow_snippet_annotations = true
    annotations_risk_level    = "Critical"
    custom_http_errors        = "404,503"
  }

  custom_error_pages = {
    enabled = true
    pages = {
      "404" = "<h1>Page Not Found</h1>"
      "503" = "<h1>Service Unavailable</h1>"
    }
  }

  tags = ["production", "kubernetes"]
}
```

### Using Outputs

```hcl
# Get kubeconfig for kubectl
output "kubeconfig" {
  value     = module.kubernetes.kubeconfig
  sensitive = true
}

# Get external IP for DNS configuration
output "ingress_ip" {
  value = module.kubernetes.ingress_external_ip
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| opentofu | >= 1.6 |
| digitalocean | >= 2.0 |
| kubernetes | >= 2.0 |
| helm | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| digitalocean | >= 2.0 |
| kubernetes | >= 2.0 |
| helm | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the Kubernetes cluster | `string` | n/a | yes |
| region | DigitalOcean region for the cluster | `string` | `"fra1"` | no |
| kubernetes_version | Kubernetes version to use | `string` | `null` (latest) | no |
| kubernetes_version_prefix | Version prefix for filtering (e.g., "1.28") | `string` | `null` | no |
| vpc_uuid | UUID of the VPC to use | `string` | `null` | no |
| auto_upgrade | Enable automatic Kubernetes version upgrades | `bool` | `false` | no |
| surge_upgrade | Enable surge upgrades for minimal downtime | `bool` | `true` | no |
| ha | Enable high availability control plane | `bool` | `false` | no |
| tags | Tags to apply to the cluster | `list(string)` | `[]` | no |
| default_node_pool | Configuration for the default node pool | `object` | See variables.tf | no |
| additional_node_pools | List of additional node pools | `list(object)` | `[]` | no |
| maintenance_policy | Maintenance policy configuration | `object` | Sunday 04:00 UTC | no |
| install_nginx_ingress | Whether to install NGINX Ingress Controller | `bool` | `true` | no |
| ingress_nginx_version | Version of the ingress-nginx Helm chart | `string` | `"4.11.3"` | no |
| ingress_controller_config | NGINX Ingress Controller configuration | `object` | See variables.tf | no |
| custom_error_pages | Custom error pages configuration | `object` | disabled | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the Kubernetes cluster |
| cluster_name | Name of the Kubernetes cluster |
| cluster_urn | URN of the Kubernetes cluster |
| cluster_endpoint | Endpoint of the Kubernetes API server |
| cluster_ipv4_address | Public IPv4 address of the cluster |
| cluster_status | Status of the Kubernetes cluster |
| cluster_version | Kubernetes version of the cluster |
| kubeconfig | Raw kubeconfig for the cluster (sensitive) |
| cluster_ca_certificate | Base64 encoded cluster CA certificate (sensitive) |
| kube_token | Kubernetes authentication token (sensitive) |
| default_node_pool_id | ID of the default node pool |
| additional_node_pool_ids | Map of additional node pool names to IDs |
| ingress_external_ip | External IP of the Ingress Controller LoadBalancer |
| ingress_load_balancer_hostname | Hostname of the Ingress Controller LoadBalancer |
<!-- END_TF_DOCS -->

## Node Pool Sizes

Common DigitalOcean droplet sizes for Kubernetes:

| Size | vCPUs | Memory | Description |
|------|-------|--------|-------------|
| `s-2vcpu-4gb` | 2 | 4 GB | Basic workloads |
| `s-4vcpu-8gb` | 4 | 8 GB | Standard workloads |
| `s-8vcpu-16gb` | 8 | 16 GB | Memory-intensive |
| `g-4vcpu-16gb` | 4 | 16 GB | General purpose |
| `g-8vcpu-32gb` | 8 | 32 GB | High performance |
| `c-4vcpu-8gb` | 4 | 8 GB | CPU-optimized |

## License

MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
