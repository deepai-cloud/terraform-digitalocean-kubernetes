variable "ingress_nginx_version" {
  description = "Version of the ingress-nginx Helm chart"
  type        = string
  default     = "4.14.1"
}

variable "ingress_controller_config" {
  description = "NGINX Ingress Controller configuration"
  type = object({
    # Proxy settings
    proxy_body_size       = optional(string, "100m")
    proxy_read_timeout    = optional(string, "60")
    proxy_send_timeout    = optional(string, "60")
    proxy_connect_timeout = optional(string, "60")
    proxy_buffer_size     = optional(string, "16k")
    proxy_buffers_number  = optional(string, "4")

    # Client settings
    client_max_body_size    = optional(string, "100m")
    client_body_timeout     = optional(string, "60")
    client_header_timeout   = optional(string, "60")
    client_body_buffer_size = optional(string, "16k")

    # Keep-alive settings
    keep_alive                     = optional(string, "75")
    keep_alive_requests            = optional(string, "1000")
    upstream_keepalive_timeout     = optional(string, "60")
    upstream_keepalive_connections = optional(string, "256")

    # Security settings
    allow_snippet_annotations = optional(bool, false)
    annotations_risk_level    = optional(string, "High")

    # Custom error pages
    custom_http_errors = optional(string, "")

    # Additional config entries
    additional_config = optional(map(string), {})
  })
  default = {}
}

variable "custom_error_pages" {
  description = "Custom error pages configuration"
  type = object({
    enabled = bool
    pages   = optional(map(string), {})
  })
  default = {
    enabled = false
    pages   = {}
  }
}

variable "metrics" {
  description = "Prometheus metrics configuration for ingress controller"
  type = object({
    enabled = bool
    port    = optional(number, 10254)
  })
  default = {
    enabled = false
    port    = 10254
  }
}
