resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

locals {
  controller_config = merge(
    {
      "proxy-body-size"                = var.ingress_controller_config.proxy_body_size
      "client-max-body-size"           = var.ingress_controller_config.client_max_body_size
      "proxy-read-timeout"             = var.ingress_controller_config.proxy_read_timeout
      "proxy-send-timeout"             = var.ingress_controller_config.proxy_send_timeout
      "proxy-connect-timeout"          = var.ingress_controller_config.proxy_connect_timeout
      "proxy-buffer-size"              = var.ingress_controller_config.proxy_buffer_size
      "proxy-buffers-number"           = var.ingress_controller_config.proxy_buffers_number
      "client-body-timeout"            = var.ingress_controller_config.client_body_timeout
      "client-header-timeout"          = var.ingress_controller_config.client_header_timeout
      "client-body-buffer-size"        = var.ingress_controller_config.client_body_buffer_size
      "keep-alive"                     = var.ingress_controller_config.keep_alive
      "keep-alive-requests"            = var.ingress_controller_config.keep_alive_requests
      "upstream-keepalive-timeout"     = var.ingress_controller_config.upstream_keepalive_timeout
      "upstream-keepalive-connections" = var.ingress_controller_config.upstream_keepalive_connections
      "allow-snippet-annotations"      = tostring(var.ingress_controller_config.allow_snippet_annotations)
      "annotations-risk-level"         = var.ingress_controller_config.annotations_risk_level
    },
    var.ingress_controller_config.custom_http_errors != "" ? {
      "custom-http-errors" = var.ingress_controller_config.custom_http_errors
    } : {},
    var.ingress_controller_config.additional_config
  )

  helm_values = {
    controller = merge(
      {
        config = local.controller_config
      },
      var.metrics.enabled ? {
        metrics = {
          enabled = true
          port    = var.metrics.port
          service = {
            annotations = {
              "prometheus.io/scrape" = "true"
              "prometheus.io/port"   = tostring(var.metrics.port)
            }
          }
        }
      } : {}
    )
    defaultBackend = {
      enabled = var.custom_error_pages.enabled
      image = var.custom_error_pages.enabled ? {
        registry = "registry.k8s.io"
        image    = "ingress-nginx/custom-error-pages"
        tag      = "v1.0.1@sha256:d8ab7de384cf41bdaa696354e19f1d0efbb0c9ac69f8682ffc0cc008a252eb76"
      } : null
      extraVolumes = var.custom_error_pages.enabled ? [{
        name = "custom-error-pages"
        configMap = {
          name = kubernetes_config_map.custom_error_pages[0].metadata[0].name
          items = [for code, _ in var.custom_error_pages.pages : {
            key  = code
            path = "${code}.html"
          }]
        }
      }] : []
      extraVolumeMounts = var.custom_error_pages.enabled ? [{
        name      = "custom-error-pages"
        mountPath = "/www"
      }] : []
    }
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_version
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name

  values = [yamlencode(local.helm_values)]

  wait = true
}

resource "kubernetes_config_map" "custom_error_pages" {
  count = var.custom_error_pages.enabled ? 1 : 0

  metadata {
    name      = "custom-error-pages"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  data = var.custom_error_pages.pages
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  depends_on = [helm_release.ingress_nginx]
}
