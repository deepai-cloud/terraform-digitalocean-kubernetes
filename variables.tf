# -----------------------------------------------------------------------------
# Cluster Configuration
# -----------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "region" {
  description = "DigitalOcean region for the cluster"
  type        = string
  default     = "fra1"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use. If not specified, uses latest available"
  type        = string
  default     = null
}

variable "kubernetes_version_prefix" {
  description = "Kubernetes version prefix for filtering available versions (e.g., '1.28')"
  type        = string
  default     = null
}

variable "vpc_uuid" {
  description = "UUID of the VPC to use. If not specified, uses default VPC"
  type        = string
  default     = null
}

variable "auto_upgrade" {
  description = "Enable automatic Kubernetes version upgrades"
  type        = bool
  default     = false
}

variable "surge_upgrade" {
  description = "Enable surge upgrades for minimal downtime"
  type        = bool
  default     = true
}

variable "ha" {
  description = "Enable high availability control plane"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the cluster"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Default Node Pool Configuration
# -----------------------------------------------------------------------------

variable "default_node_pool" {
  description = "Configuration for the default node pool"
  type = object({
    name       = optional(string)
    size       = string
    min_nodes  = number
    max_nodes  = number
    auto_scale = bool
    labels     = optional(map(string), {})
    tags       = optional(list(string), [])
  })
  default = {
    name       = null
    size       = "s-4vcpu-8gb"
    min_nodes  = 1
    max_nodes  = 6
    auto_scale = true
    labels     = {}
    tags       = []
  }
}

# -----------------------------------------------------------------------------
# Additional Node Pools
# -----------------------------------------------------------------------------

variable "additional_node_pools" {
  description = "List of additional node pools to create"
  type = list(object({
    name       = string
    size       = string
    min_nodes  = number
    max_nodes  = number
    auto_scale = bool
    labels     = optional(map(string), {})
    tags       = optional(list(string), [])
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Maintenance Policy
# -----------------------------------------------------------------------------

variable "maintenance_policy" {
  description = "Maintenance policy for automatic updates"
  type = object({
    start_time = string
    day        = string
  })
  default = {
    start_time = "04:00"
    day        = "sunday"
  }
}

# -----------------------------------------------------------------------------
# Ingress Controller Configuration
# -----------------------------------------------------------------------------

variable "install_nginx_ingress" {
  description = "Whether to install NGINX Ingress Controller"
  type        = bool
  default     = true
}

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
