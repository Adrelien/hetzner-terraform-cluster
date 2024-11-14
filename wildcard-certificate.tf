resource "kubernetes_manifest" "wildcard_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "wildcard-cert"
      namespace = "default"
    }
    spec = {
      secretName = "wildcard-tls"
      issuerRef = {
        name = "letsencrypt-wildcard"
        kind = "ClusterIssuer"
      }
      commonName = "*.${var.domain}"
      dnsNames = concat(
        ["*.${var.domain}"],
        [for subdomain in var.subdomains : "*.${subdomain}.${var.domain}"],
        [var.domain]
      )
    }
  }

  depends_on = [kubernetes_manifest.letsencrypt_wildcard_issuer]
}