data "digitalocean_kubernetes_versions" "cluster" {
  version_prefix = var.kubernetes_version_prefix
}

resource "digitalocean_kubernetes_cluster" "this" {
  name    = var.cluster_name
  region  = var.region
  version = var.kubernetes_version != null ? var.kubernetes_version : data.digitalocean_kubernetes_versions.cluster.latest_version

  vpc_uuid    = var.vpc_uuid
  auto_upgrade = var.auto_upgrade
  surge_upgrade = var.surge_upgrade
  ha          = var.ha

  node_pool {
    name       = "${var.cluster_name}-default"
    size       = var.default_node_pool.size
    min_nodes  = var.default_node_pool.min_nodes
    max_nodes  = var.default_node_pool.max_nodes
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
  for_each = { for idx, pool in var.additional_node_pools : pool.name => pool }

  cluster_id = digitalocean_kubernetes_cluster.this.id
  name       = each.value.name
  size       = each.value.size
  min_nodes  = each.value.min_nodes
  max_nodes  = each.value.max_nodes
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

provider "kubernetes" {
  alias                  = "cluster"
  host                   = digitalocean_kubernetes_cluster.this.endpoint
  token                  = digitalocean_kubernetes_cluster.this.kube_config[0].token
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  alias = "cluster"
  kubernetes {
    host                   = digitalocean_kubernetes_cluster.this.endpoint
    token                  = digitalocean_kubernetes_cluster.this.kube_config[0].token
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
  }
}

module "ingress" {
  count  = var.install_nginx_ingress ? 1 : 0
  source = "./modules/ingress"

  ingress_nginx_version     = var.ingress_nginx_version
  ingress_controller_config = var.ingress_controller_config
  custom_error_pages        = var.custom_error_pages

  providers = {
    kubernetes = kubernetes.cluster
    helm       = helm.cluster
  }

  depends_on = [digitalocean_kubernetes_cluster.this]
}
