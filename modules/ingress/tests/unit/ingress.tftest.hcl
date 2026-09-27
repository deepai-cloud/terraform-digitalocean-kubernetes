mock_provider "kubernetes" {}
mock_provider "helm" {}

run "default_installation" {
  command = plan

  assert {
    condition     = !yamldecode(helm_release.ingress_nginx.values[0]).defaultBackend.enabled
    error_message = "Custom error pages must be disabled by default."
  }
}

run "custom_error_pages_and_metrics" {
  command = apply

  variables {
    custom_error_pages = {
      enabled = true
      pages   = { "503" = "<h1>Unavailable</h1>" }
    }
    ingress_controller_config = {
      custom_http_errors = "503"
      additional_config  = { "proxy-body-size" = "64m" }
    }
    metrics = { enabled = true, port = 10255 }
  }

  assert {
    condition = (
      yamldecode(helm_release.ingress_nginx.values[0]).defaultBackend.extraVolumes[0].configMap.name == kubernetes_config_map.custom_error_pages[0].metadata[0].name &&
      yamldecode(helm_release.ingress_nginx.values[0]).defaultBackend.extraVolumes[0].configMap.items[0].path == "503.html"
    )
    error_message = "Helm must mount the managed ConfigMap's error pages."
  }

  assert {
    condition = (
      yamldecode(helm_release.ingress_nginx.values[0]).controller.metrics.port == 10255 &&
      yamldecode(helm_release.ingress_nginx.values[0]).controller.metrics.service.annotations["prometheus.io/port"] == "10255" &&
      yamldecode(helm_release.ingress_nginx.values[0]).controller.config["proxy-body-size"] == "64m"
    )
    error_message = "Metrics settings and additional controller configuration must reach the Helm chart."
  }
}
