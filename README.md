# DigitalOcean Kubernetes Terraform module

Create and manage DigitalOcean Kubernetes (DOKS) clusters with Terraform or OpenTofu. Maintained by [deepai-cloud](https://github.com/deepai-cloud).

- Autoscaling or fixed-size worker pools, with optional labels, tags, and taints.
- Optional high availability control plane, VPC selection, and maintenance windows.
- Kubeconfig and cluster outputs for connecting applications and tooling.
- Optional legacy ingress-nginx integration with metrics and custom error pages.

## Quick start

Install Terraform **1.6+** or OpenTofu **1.6+**, and create a DigitalOcean API token with permission to manage Kubernetes and its associated resources.

Create a `main.tf` in an empty directory:

```hcl
terraform {
  required_version = ">= 1.6"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.69"
    }
  }
}

# Reads DIGITALOCEAN_TOKEN from your environment.
provider "digitalocean" {}

module "kubernetes" {
  source = "git::https://github.com/deepai-cloud/terraform-digitalocean-kubernetes.git?ref=v1.3.0" # x-release-please-version

  cluster_name          = "my-cluster"
  region                = "fra1"
  install_nginx_ingress = false
}

output "kubeconfig" {
  description = "Kubeconfig for kubectl access"
  value       = module.kubernetes.kubeconfig
  sensitive   = true
}
```

Set your token, download the module and providers, and review the infrastructure plan:

```bash
export DIGITALOCEAN_TOKEN="your-digitalocean-api-token"
terraform init
terraform plan
terraform apply
```

`terraform init` downloads the module automatically; cloning this repository is unnecessary. `terraform apply` provisions billable DigitalOcean resources. OpenTofu users can replace `terraform` with `tofu` in these commands.

To connect without overwriting your existing kubeconfig:

```bash
umask 077
terraform output -raw kubeconfig > kubeconfig
export KUBECONFIG="$PWD/kubeconfig"
kubectl get nodes
```

Store Terraform state securely: it contains cluster credentials, including outputs marked sensitive. Remove the example infrastructure when finished with `terraform destroy`.

## Installation options

### Terraform Registry

The intended Registry address is `deepai-cloud/kubernetes/digitalocean`. After the repository's [one-time Registry registration](docs/publishing.md), use:

```hcl
module "kubernetes" {
  source  = "deepai-cloud/kubernetes/digitalocean"
  version = "1.3.0" # x-release-please-version

  cluster_name          = "my-cluster"
  install_nginx_ingress = false
}
```

Until that registration is complete, use the pinned GitHub source in the quick start. OpenTofu users can explicitly select the Terraform Registry with `source = "registry.terraform.io/deepai-cloud/kubernetes/digitalocean"`.

### GitHub or archive download

The pinned HTTPS source above works with both Terraform and OpenTofu and does not require GitHub credentials for this public repository. Git-based sources require Git to be installed. Change the `ref` to select another released version, then run `terraform init -upgrade`.

You can also [download the source archive](https://github.com/deepai-cloud/terraform-digitalocean-kubernetes/archive/refs/tags/v1.3.0.zip). <!-- x-release-please-version -->

## Examples

- [Basic](examples/basic): one fixed-size worker node, with ingress disabled.
- [Complete](examples/complete): multiple autoscaling pools, taints, legacy ingress, custom error pages, and metrics.
- [Ingress submodule](modules/ingress): install the legacy controller into an existing cluster with caller-configured Kubernetes and Helm providers.

Examples use local relative sources so contributors can validate changes before releasing them. Use a versioned source from the quick start in your own projects.

### Fixed-size worker pool

Only override the settings you need:

```hcl
default_node_pool = {
  size       = "s-2vcpu-4gb"
  auto_scale = false
  node_count = 1
}
```

With autoscaling enabled, `min_nodes` and `max_nodes` control capacity and `node_count` is ignored. With autoscaling disabled, `node_count` controls capacity and scaling bounds are omitted. Additional pools also support these options and must have unique names. Scale-to-zero availability depends on your DigitalOcean account; the examples use at least one node.

### Existing ingress users

Set `install_nginx_ingress = true` to retain the optional integration. Its existing default remains `true` for compatibility with version 1.x callers. New examples explicitly disable it because [upstream ingress-nginx was retired in March 2026](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/). Select a maintained ingress or Gateway API controller for new production deployments.

The root module configures Kubernetes and Helm providers from its cluster outputs. Terraform therefore does not support `count`, `for_each`, or `depends_on` on calls to this root module. Use separate named module blocks for multiple clusters. The standalone ingress submodule accepts providers from its caller.

`kubernetes_version` selects the version at initial creation. The cluster ignores later version changes to prevent accidental downgrades after upgrades outside Terraform. Use DigitalOcean's upgrade workflow for an existing cluster. `kubernetes_version_prefix` only applies when no exact version is supplied.

## Development and releases

Run validation without creating infrastructure:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
# Provider mocking requires Terraform 1.7+ or OpenTofu 1.11+.
terraform test -test-directory=tests/unit
terraform -chdir=modules/ingress init -backend=false
terraform -chdir=modules/ingress test -test-directory=tests/unit
```

Regenerate the reference below using `terraform-docs` v0.20.0:

```bash
terraform-docs .
terraform-docs modules/ingress
```

CI checks Terraform 1.6.6, Terraform 1.9.8, and OpenTofu 1.11.2, including both examples and the ingress submodule. Releases validate before publication. See [publishing instructions](docs/publishing.md) and the [changelog](CHANGELOG.md).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| digitalocean | ~> 2.69 |
| helm | ~> 2.17 |
| kubernetes | ~> 2.38 |

## Providers

| Name | Version |
|------|---------|
| digitalocean | ~> 2.69 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| ingress | ./modules/ingress | n/a |

## Resources

| Name | Type |
|------|------|
| [digitalocean_kubernetes_cluster.this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_cluster) | resource |
| [digitalocean_kubernetes_node_pool.additional](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_node_pool) | resource |
| [digitalocean_kubernetes_versions.cluster](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/kubernetes_versions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the Kubernetes cluster | `string` | n/a | yes |
| additional_node_pools | Additional node pools with unique names. Set auto_scale = false and node_count for fixed-size pools | <pre>list(object({<br/>    name       = string<br/>    size       = string<br/>    node_count = optional(number, 1)<br/>    min_nodes  = optional(number, 1)<br/>    max_nodes  = optional(number, 6)<br/>    auto_scale = optional(bool, true)<br/>    labels     = optional(map(string), {})<br/>    tags       = optional(list(string), [])<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = string<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| auto_upgrade | Enable automatic Kubernetes version upgrades | `bool` | `false` | no |
| custom_error_pages | Custom error pages configuration | <pre>object({<br/>    enabled = bool<br/>    pages   = optional(map(string), {})<br/>  })</pre> | <pre>{<br/>  "enabled": false,<br/>  "pages": {}<br/>}</pre> | no |
| default_node_pool | Default node pool. Set auto_scale = false and node_count for a fixed-size pool | <pre>object({<br/>    name       = optional(string)<br/>    size       = optional(string, "s-4vcpu-8gb")<br/>    node_count = optional(number, 1)<br/>    min_nodes  = optional(number, 1)<br/>    max_nodes  = optional(number, 6)<br/>    auto_scale = optional(bool, true)<br/>    labels     = optional(map(string), {})<br/>    tags       = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| ha | Enable high availability control plane | `bool` | `false` | no |
| ingress_controller_config | NGINX Ingress Controller configuration | <pre>object({<br/>    # Proxy settings<br/>    proxy_body_size       = optional(string, "100m")<br/>    proxy_read_timeout    = optional(string, "60")<br/>    proxy_send_timeout    = optional(string, "60")<br/>    proxy_connect_timeout = optional(string, "60")<br/>    proxy_buffer_size     = optional(string, "16k")<br/>    proxy_buffers_number  = optional(string, "4")<br/><br/>    # Client settings<br/>    client_max_body_size    = optional(string, "100m")<br/>    client_body_timeout     = optional(string, "60")<br/>    client_header_timeout   = optional(string, "60")<br/>    client_body_buffer_size = optional(string, "16k")<br/><br/>    # Keep-alive settings<br/>    keep_alive                     = optional(string, "75")<br/>    keep_alive_requests            = optional(string, "1000")<br/>    upstream_keepalive_timeout     = optional(string, "60")<br/>    upstream_keepalive_connections = optional(string, "256")<br/><br/>    # Security settings<br/>    allow_snippet_annotations = optional(bool, false)<br/>    annotations_risk_level    = optional(string, "High")<br/><br/>    # Custom error pages<br/>    custom_http_errors = optional(string, "")<br/><br/>    # Additional config entries<br/>    additional_config = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| ingress_metrics | Prometheus metrics configuration for ingress controller | <pre>object({<br/>    enabled = bool<br/>    port    = optional(number, 10254)<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "port": 10254<br/>}</pre> | no |
| ingress_nginx_version | Version of the ingress-nginx Helm chart | `string` | `"4.14.1"` | no |
| install_nginx_ingress | Whether to install NGINX Ingress Controller | `bool` | `true` | no |
| kubernetes_version | Kubernetes version for initial creation. If null, uses the latest matching version. Later version changes are ignored to avoid downgrades after automatic upgrades | `string` | `null` | no |
| kubernetes_version_prefix | Kubernetes version prefix for filtering available versions; ignored when kubernetes_version is set | `string` | `null` | no |
| maintenance_policy | Maintenance policy for automatic updates | <pre>object({<br/>    start_time = string<br/>    day        = string<br/>  })</pre> | <pre>{<br/>  "day": "sunday",<br/>  "start_time": "04:00"<br/>}</pre> | no |
| region | DigitalOcean region for the cluster | `string` | `"fra1"` | no |
| surge_upgrade | Enable surge upgrades for minimal downtime | `bool` | `true` | no |
| tags | Tags to apply to the cluster | `list(string)` | `[]` | no |
| vpc_uuid | UUID of the VPC to use. If not specified, uses default VPC | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| additional_node_pool_ids | Map of additional node pool names to their IDs |
| cluster_ca_certificate | Base64 encoded cluster CA certificate |
| cluster_endpoint | Endpoint of the Kubernetes API server |
| cluster_id | ID of the Kubernetes cluster |
| cluster_ipv4_address | Public IPv4 address of the Kubernetes cluster |
| cluster_name | Name of the Kubernetes cluster |
| cluster_status | Status of the Kubernetes cluster |
| cluster_urn | URN of the Kubernetes cluster |
| cluster_version | Kubernetes version of the cluster |
| default_node_pool_id | ID of the default node pool |
| ingress_external_ip | External IP address of the NGINX Ingress Controller LoadBalancer |
| ingress_load_balancer_hostname | Hostname of the NGINX Ingress Controller LoadBalancer |
| kube_token | Kubernetes authentication token |
| kubeconfig | Raw kubeconfig for the cluster |
<!-- END_TF_DOCS -->

## License

[MIT](LICENSE).
