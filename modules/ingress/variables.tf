variable "ingress_nginx_version" {
  description = "Version of the ingress-nginx Helm chart"
  type        = string
  default     = "4.14.1"
}

variable "ingress_controller_config" {
  description = "NGINX Ingress Controller configuration"
  type = object({
    proxy_body_size                = string
    proxy_read_timeout             = string
    proxy_send_timeout             = string
    proxy_connect_timeout          = string
    proxy_buffer_size              = string
    proxy_buffers_number           = string
    client_max_body_size           = string
    client_body_timeout            = string
    client_header_timeout          = string
    client_body_buffer_size        = string
    keep_alive                     = string
    keep_alive_requests            = string
    upstream_keepalive_timeout     = string
    upstream_keepalive_connections = string
    allow_snippet_annotations      = bool
    annotations_risk_level         = string
    custom_http_errors             = string
    additional_config              = map(string)
  })
}

variable "custom_error_pages" {
  description = "Custom error pages configuration"
  type = object({
    enabled = bool
    pages   = map(string)
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
