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
  description = "Kubernetes version for initial creation. If null, uses the latest matching version. Later version changes are ignored to avoid downgrades after automatic upgrades"
  type        = string
  default     = null
}

variable "kubernetes_version_prefix" {
  description = "Kubernetes version prefix for filtering available versions; ignored when kubernetes_version is set"
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
  description = "Default node pool. Set auto_scale = false and node_count for a fixed-size pool"
  type = object({
    name       = optional(string)
    size       = optional(string, "s-4vcpu-8gb")
    node_count = optional(number, 1)
    min_nodes  = optional(number, 1)
    max_nodes  = optional(number, 6)
    auto_scale = optional(bool, true)
    labels     = optional(map(string), {})
    tags       = optional(list(string), [])
  })
  default = {}

  validation {
    condition = var.default_node_pool.auto_scale ? (
      var.default_node_pool.min_nodes >= 1 &&
      floor(var.default_node_pool.min_nodes) == var.default_node_pool.min_nodes &&
      var.default_node_pool.max_nodes >= var.default_node_pool.min_nodes &&
      floor(var.default_node_pool.max_nodes) == var.default_node_pool.max_nodes
      ) : (
      var.default_node_pool.node_count >= 1 &&
      floor(var.default_node_pool.node_count) == var.default_node_pool.node_count
    )
    error_message = "The default pool requires integer autoscaling bounds with 1 <= min_nodes <= max_nodes, or a positive integer node_count when auto_scale is false."
  }
}

# -----------------------------------------------------------------------------
# Additional Node Pools
# -----------------------------------------------------------------------------

variable "additional_node_pools" {
  description = "Additional node pools with unique names. Set auto_scale = false and node_count for fixed-size pools"
  type = list(object({
    name       = string
    size       = string
    node_count = optional(number, 1)
    min_nodes  = optional(number, 1)
    max_nodes  = optional(number, 6)
    auto_scale = optional(bool, true)
    labels     = optional(map(string), {})
    tags       = optional(list(string), [])
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  default = []

  validation {
    condition     = length(distinct([for pool in var.additional_node_pools : pool.name])) == length(var.additional_node_pools)
    error_message = "Additional node pool names must be unique."
  }

  validation {
    condition = alltrue([for pool in var.additional_node_pools : pool.auto_scale ? (
      pool.min_nodes >= 0 && floor(pool.min_nodes) == pool.min_nodes &&
      pool.max_nodes >= max(1, pool.min_nodes) && floor(pool.max_nodes) == pool.max_nodes
      ) : (
      pool.node_count >= 1 && floor(pool.node_count) == pool.node_count
    )])
    error_message = "Additional pools require integer autoscaling bounds with 0 <= min_nodes <= max_nodes and max_nodes >= 1, or a positive integer node_count when auto_scale is false."
  }
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

variable "ingress_metrics" {
  description = "Prometheus metrics configuration for ingress controller"
  type = object({
    enabled = bool
    port    = optional(number, 10254)
  })
  default = {
    enabled = true
    port    = 10254
  }
}
