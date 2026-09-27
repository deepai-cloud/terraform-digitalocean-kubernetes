terraform {
  required_version = ">= 1.6"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.69"
    }
  }
}

# Reads DIGITALOCEAN_TOKEN from the environment.
provider "digitalocean" {}

module "kubernetes" {
  source = "../.."

  cluster_name          = var.cluster_name
  region                = var.region
  install_nginx_ingress = false

  default_node_pool = {
    size       = "s-2vcpu-4gb"
    auto_scale = false
    node_count = 1
  }
}
