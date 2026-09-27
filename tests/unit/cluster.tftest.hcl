mock_provider "digitalocean" {
  mock_resource "digitalocean_kubernetes_cluster" {
    defaults = {
      kube_config = [{
        raw_config             = "mock-kubeconfig"
        host                   = "https://cluster.example.test"
        token                  = "mock-token"
        cluster_ca_certificate = "bW9jay1jYQ=="
        client_certificate     = ""
        client_key             = ""
        expires_at             = "2030-01-01T00:00:00Z"
      }]
    }
  }

  mock_data "digitalocean_kubernetes_versions" {
    defaults = {
      latest_version = "1.32.0-do.0"
    }
  }
}

mock_provider "kubernetes" {
  alias = "cluster"
}

mock_provider "helm" {
  alias = "cluster"
}

variables {
  cluster_name          = "test-cluster"
  install_nginx_ingress = false
}

run "autoscaling_defaults" {
  command = plan

  assert {
    condition = (
      digitalocean_kubernetes_cluster.this.node_pool[0].name == "test-cluster-default" &&
      digitalocean_kubernetes_cluster.this.node_pool[0].auto_scale &&
      digitalocean_kubernetes_cluster.this.node_pool[0].min_nodes == 1 &&
      digitalocean_kubernetes_cluster.this.node_pool[0].max_nodes == 6
    )
    error_message = "Default autoscaling settings must remain compatible with existing callers."
  }

  assert {
    condition     = digitalocean_kubernetes_cluster.this.version == "1.32.0-do.0"
    error_message = "An unspecified version must use the available Kubernetes version."
  }

  assert {
    condition     = output.ingress_external_ip == null && output.ingress_load_balancer_hostname == null
    error_message = "Disabling ingress must produce null ingress outputs."
  }
}

run "fixed_size_pools_and_explicit_version" {
  command = plan

  variables {
    kubernetes_version = "1.31.0-do.0"
    default_node_pool = {
      name       = "workers"
      auto_scale = false
      node_count = 2
    }
    additional_node_pools = [{
      name       = "batch"
      size       = "s-2vcpu-4gb"
      auto_scale = false
      node_count = 3
    }]
  }

  assert {
    condition = (
      digitalocean_kubernetes_cluster.this.node_pool[0].name == "workers" &&
      digitalocean_kubernetes_cluster.this.node_pool[0].node_count == 2 &&
      digitalocean_kubernetes_cluster.this.node_pool[0].min_nodes == null &&
      digitalocean_kubernetes_cluster.this.node_pool[0].max_nodes == null &&
      digitalocean_kubernetes_node_pool.additional["batch"].node_count == 3 &&
      digitalocean_kubernetes_node_pool.additional["batch"].min_nodes == null &&
      digitalocean_kubernetes_node_pool.additional["batch"].max_nodes == null
    )
    error_message = "Fixed-size pools must use node_count without autoscaling bounds."
  }

  assert {
    condition = (
      digitalocean_kubernetes_cluster.this.version == "1.31.0-do.0" &&
      length(data.digitalocean_kubernetes_versions.cluster) == 0
    )
    error_message = "An explicit Kubernetes version must skip the version lookup."
  }
}

run "invalid_default_scaling_bounds" {
  command = plan

  variables {
    default_node_pool = { min_nodes = 3, max_nodes = 2 }
  }

  expect_failures = [var.default_node_pool]
}

run "invalid_fixed_size" {
  command = plan

  variables {
    additional_node_pools = [{
      name       = "batch"
      size       = "s-2vcpu-4gb"
      auto_scale = false
      node_count = 0
    }]
  }

  expect_failures = [var.additional_node_pools]
}
