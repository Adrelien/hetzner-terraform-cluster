resource "kubernetes_manifest" "tls_store" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "TLSStore"
    metadata = {
      name      = "default"
      namespace = "default"
    }
    spec = {
      defaultCertificate = {
        secretName = "wildcard-tls"
      }
    }
  }
}
# Traefik IP Whitelist Middleware
resource "kubernetes_manifest" "traefik_ip_whitelist_middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "ip-whitelist"
      namespace = "traefik"
    }
    spec = {
      ipWhiteList = {
        sourceRange = ["5.78.87.18"]
      }
    }
  }
}

# Longhorn IP Whitelist Middleware
resource "kubernetes_manifest" "longhorn_ip_whitelist_middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "ip-whitelist"
      namespace = "longhorn-system"
    }
    spec = {
      ipWhiteList = {
        sourceRange = ["5.78.87.18"]
      }
    }
  }
}

# ArgoCD IP Whitelist Middleware
resource "kubernetes_manifest" "argocd_ip_whitelist_middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "ip-whitelist"
      namespace = "argocd"
    }
    spec = {
      ipWhiteList = {
        sourceRange = ["5.78.87.18"]
      }
    }
  }
}

# Prometheus IP Whitelist Middleware
resource "kubernetes_manifest" "prometheus_ip_whitelist_middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "ip-whitelist"
      namespace = "prometheus"
    }
    spec = {
      ipWhiteList = {
        sourceRange = ["5.78.87.18"]
      }
    }
  }
}

# Grafana IP Whitelist Middleware
resource "kubernetes_manifest" "grafana_ip_whitelist_middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "ip-whitelist"
      namespace = "grafana"
    }
    spec = {
      ipWhiteList = {
        sourceRange = ["5.78.87.18"]
      }
    }
  }
}

# Traefik Dashboard IngressRoute
resource "kubernetes_manifest" "traefik_dashboard_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "traefik-dashboard"
      namespace = "traefik"
    }
    spec = {
      entryPoints = ["web", "websecure"]
      routes = [
        {
          kind  = "Rule"
          match = "Host(`${var.traefik_hostname}`)"
          middlewares = [
            {
              name = "ip-whitelist"
            }
          ]
          services = [
            {
              name = "api@internal"
              kind = "TraefikService"
            }
          ]
        }
      ]
    }
  }

  depends_on = [module.kube-hetzner, kubernetes_manifest.traefik_ip_whitelist_middleware]
}

# Longhorn Dashboard IngressRoute
resource "kubernetes_manifest" "longhorn_dashboard_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "longhorn-dashboard"
      namespace = "longhorn-system"
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          kind     = "Rule"
          match    = "Host(`${var.longhorn_hostname}`)"
          priority = 10
          middlewares = [
            {
              name = "ip-whitelist"
            }
          ]
          services = [
            {
              name = "longhorn-frontend"
              port = 80
            }
          ]
        }
      ]
      tls = {
        secretName = "wildcard-tls"
      }
    }
  }

  depends_on = [module.kube-hetzner, kubernetes_manifest.wildcard_certificate, kubernetes_manifest.longhorn_ip_whitelist_middleware]
}

# ArgoCD IngressRoute
resource "kubernetes_manifest" "argocd_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "argocd-server"
      namespace = "argocd"
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          kind     = "Rule"
          match    = "Host(`${var.argocd_hostname}`)"
          priority = 10
          middlewares = [
            {
              name = "ip-whitelist"
            }
          ]
          services = [
            {
              name = "argocd-server"
              port = 80
            }
          ]
        },
        {
          kind     = "Rule"
          match    = "Host(`${var.argocd_hostname}`) && Headers(`Content-Type`, `application/grpc`)"
          priority = 11
          middlewares = [
            {
              name = "ip-whitelist"
            }
          ]
          services = [
            {
              name   = "argocd-server"
              port   = 80
              scheme = "h2c"
            }
          ]
        }
      ]
      tls = {
        certResolver = "default"
      }
    }
  }

  depends_on = [module.argocd, kubernetes_manifest.argocd_ip_whitelist_middleware]
}

# Prometheus Dashboard IngressRoute
resource "kubernetes_manifest" "prometheus_dashboard_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "prometheus"
      namespace = "prometheus"
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          kind     = "Rule"
          match    = "Host(`${var.prometheus_hostname}`)"
          priority = 10
          middlewares = [
            {
              name = "ip-whitelist"
            }
          ]
          services = [
            {
              name = "prometheus-server"
              port = 80
            }
          ]
        }
      ]
      tls = {
        certResolver = "default"
      }
    }
  }

  depends_on = [module.prometheus, kubernetes_manifest.prometheus_ip_whitelist_middleware]
}

# Grafana Dashboard IngressRoute
resource "kubernetes_manifest" "grafana_dashboard_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "grafana"
      namespace = "grafana"
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          kind     = "Rule"
          match    = "Host(`${var.grafana_hostname}`)"
          priority = 10
          middlewares = [
            {
              name = "ip-whitelist"
            }
          ]
          services = [
            {
              name = "grafana"
              port = 80
            }
          ]
        }
      ]
      tls = {
        certResolver = "default"
      }
    }
  }

  depends_on = [module.grafana, kubernetes_manifest.grafana_ip_whitelist_middleware]
}
# Production API IngressRoute
resource "kubernetes_manifest" "hive_api_ingressroute_prod" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "hive-api-ingressroute-prod"
      namespace = "telemetry-hive-prod"
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          kind     = "Rule"
          match    = "Host(`telemetryhive.com`) && PathPrefix(`/api/v1`)"
          priority = 20
          services = [
            {
              name = "hive-backend"
              port = 8000
            }
          ]
          middlewares = [
            {
              name = "strip-api-prefix-prod"
              namespace = "telemetry-hive-prod"
            }
          ]
        }
      ]
      tls = {
        certResolver = "default"
      }
    }
  }
  depends_on = [kubernetes_manifest.wildcard_certificate]
}

# Strip Prefix Middleware for Prod
resource "kubernetes_manifest" "strip_api_prefix_middleware_prod" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "strip-api-prefix-prod"
      namespace = "telemetry-hive-prod"
    }
    spec = {
      stripPrefix = {
        prefixes = ["/api/v1"]
      }
    }
  }
}



# Dev Frontend IngressRoute
resource "kubernetes_manifest" "hive_frontend_ingressroute_prod" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "hive-frontend-ingressroute-prod"
      namespace = "telemetry-hive-prod"
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          kind     = "Rule"
          match    = "Host(`telemetryhive.com`)"
          priority = 10
          services = [
            {
              name = "hive-frontend"
              port = 3000
            }
          ]
        }
      ]
      tls = {
        certResolver = "default"
      }
    }
  }

  depends_on = [kubernetes_manifest.wildcard_certificate]
}