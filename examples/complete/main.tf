terraform {
  required_version = ">= 1.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

module "kubernetes" {
  source = "../../"

  cluster_name = "example-cluster"
  region       = "fra1"
  ha           = false

  default_node_pool = {
    size       = "s-4vcpu-8gb"
    min_nodes  = 1
    max_nodes  = 6
    auto_scale = true
    labels = {
      "node-type" = "general"
    }
    tags = ["kubernetes", "example"]
  }

  additional_node_pools = [
    {
      name       = "high-memory"
      size       = "g-8vcpu-32gb"
      min_nodes  = 0
      max_nodes  = 3
      auto_scale = true
      labels = {
        "node-type" = "high-memory"
      }
      tags = []
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
    # Large file upload support (15GB)
    proxy_body_size      = "15g"
    client_max_body_size = "15g"

    # Extended timeouts for large uploads (6 hours)
    proxy_read_timeout    = "21600"
    proxy_send_timeout    = "21600"
    proxy_connect_timeout = "60"
    client_body_timeout   = "21600"
    client_header_timeout = "60"

    # Buffer settings
    proxy_buffer_size       = "64k"
    proxy_buffers_number    = "8"
    client_body_buffer_size = "128k"

    # Keep-alive settings
    keep_alive                     = "21600"
    keep_alive_requests            = "10000"
    upstream_keepalive_timeout     = "21600"
    upstream_keepalive_connections = "1000"

    # Security settings
    allow_snippet_annotations = true
    annotations_risk_level    = "Critical"

    # Custom error pages
    custom_http_errors = "404,503"

    additional_config = {}
  }

  custom_error_pages = {
    enabled = true
    pages = {
      "404" = <<-EOT
        <!DOCTYPE html>
        <html>
        <head><title>404 Not Found</title></head>
        <body>
          <h1>Page Not Found</h1>
          <p>The requested page could not be found.</p>
        </body>
        </html>
      EOT
      "503" = <<-EOT
        <!DOCTYPE html>
        <html>
        <head>
          <title>Service Unavailable</title>
          <script>setTimeout(function() { location.reload(); }, 5000);</script>
        </head>
        <body>
          <h1>Service Temporarily Unavailable</h1>
          <p>Please wait, the page will refresh automatically.</p>
        </body>
        </html>
      EOT
    }
  }

  tags = ["example", "kubernetes"]
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.kubernetes.cluster_endpoint
}

output "kubeconfig" {
  description = "Kubeconfig for cluster access"
  value       = module.kubernetes.kubeconfig
  sensitive   = true
}

output "ingress_ip" {
  description = "External IP for Ingress Controller"
  value       = module.kubernetes.ingress_external_ip
}
