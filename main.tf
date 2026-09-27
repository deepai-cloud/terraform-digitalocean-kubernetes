data "digitalocean_kubernetes_versions" "cluster" {
  count = var.kubernetes_version == null ? 1 : 0

  version_prefix = var.kubernetes_version_prefix
}

resource "digitalocean_kubernetes_cluster" "this" {
  name    = var.cluster_name
  region  = var.region
  version = var.kubernetes_version != null ? var.kubernetes_version : data.digitalocean_kubernetes_versions.cluster[0].latest_version

  vpc_uuid      = var.vpc_uuid
  auto_upgrade  = var.auto_upgrade
  surge_upgrade = var.surge_upgrade
  ha            = var.ha

  node_pool {
    name       = var.default_node_pool.name != null ? var.default_node_pool.name : "${var.cluster_name}-default"
    size       = var.default_node_pool.size
    node_count = var.default_node_pool.auto_scale ? null : var.default_node_pool.node_count
    min_nodes  = var.default_node_pool.auto_scale ? var.default_node_pool.min_nodes : null
    max_nodes  = var.default_node_pool.auto_scale ? var.default_node_pool.max_nodes : null
    auto_scale = var.default_node_pool.auto_scale
    labels     = var.default_node_pool.labels
    tags       = var.default_node_pool.tags
  }

  maintenance_policy {
    start_time = var.maintenance_policy.start_time
    day        = var.maintenance_policy.day
  }

  lifecycle {
    ignore_changes = [version]
  }

  tags = var.tags
}

resource "digitalocean_kubernetes_node_pool" "additional" {
  for_each = { for pool in var.additional_node_pools : pool.name => pool }

  cluster_id = digitalocean_kubernetes_cluster.this.id
  name       = each.value.name
  size       = each.value.size
  node_count = each.value.auto_scale ? null : each.value.node_count
  min_nodes  = each.value.auto_scale ? each.value.min_nodes : null
  max_nodes  = each.value.auto_scale ? each.value.max_nodes : null
  auto_scale = each.value.auto_scale
  labels     = each.value.labels
  tags       = each.value.tags

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
}

module "ingress" {
  count  = var.install_nginx_ingress ? 1 : 0
  source = "./modules/ingress"

  ingress_nginx_version     = var.ingress_nginx_version
  ingress_controller_config = var.ingress_controller_config
  custom_error_pages        = var.custom_error_pages
  metrics                   = var.ingress_metrics

  providers = {
    kubernetes = kubernetes.cluster
    helm       = helm.cluster
  }

  depends_on = [digitalocean_kubernetes_cluster.this]
}
