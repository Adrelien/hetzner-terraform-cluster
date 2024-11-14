# Hcloud
variable "hcloud_token" {
  sensitive = true
}

# Snapshot IDs
variable "microos_x86_snapshot_id" {
  description = "MicroOS x86 Snapshot ID"
  type        = string
  default     = ""
}

variable "microos_arm_snapshot_id" {
  description = "MicroOS ARM Snapshot ID"
  type        = string
  default     = ""
}

## ArgoCD
variable "argocd_admin_password" {
  description = "Agrocd Admin Password"
  type        = string
  default     = ""
}

# Prometheus
variable "prometheus_storageclass_name" {
  description = "PVC Storage Class"
  type        = string
  default     = ""
}

variable "prometheus_storage_size" {
  type        = string
  description = "PVC Storage Size"
  default     = "5Gi"
}

variable "prometheus_retention_period" {
  description = "Retention period for Prometheus data"
  type        = string
  default     = "7d"
}

# Grafana
variable "grafana_storageclass_name" {
  description = "PVC Storage Class"
  type        = string
  default     = ""
}

variable "grafana_enable_persistence" {
  type        = bool
  description = "Enabled the persistence?"
  default     = false
}

variable "grafana_storage_size" {
  type        = string
  description = "PVC Storage Size"
  default     = "2Gi"
}

variable "grafana_admin_password" {
  description = "Default Admin Password"
  type        = string
  default     = ""
}

# Traefik Host name
variable "traefik_hostname" {
  description = "Hostname for Traefik IngressRoute"
  default     = "traefik.example.com"
}

# Longhorn Host name
variable "longhorn_hostname" {
  description = "Hostname for Longhorn IngressRoute"
  default     = "longhorn.example.com"
}

# Argocd Host name
variable "argocd_hostname" {
  description = "Hostname for ArgoCD IngressRoute"
  default     = "argocd.example.com"
}

# Prometheus Host name
variable "prometheus_hostname" {
  description = "Hostname for Prometheus IngressRoute"
  default     = "prometheus.example.com"
}

# Grafana Host name
variable "grafana_hostname" {
  description = "Hostname for Grafana IngressRoute"
  default     = "grafana.example.com"
}
variable "cloudflare_api_token" {
  description = "Cloudflare API Token for DNS challenge"
  type        = string
  sensitive   = true
}

variable "cifs_username" {
  description = "CIFS username"
  type        = string
}

variable "cifs_password" {
  description = "CIFS password"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "The main domain for the wildcard certificate"
  type        = string
}

variable "subdomains" {
  description = "List of subdomains to include in the certificate"
  type        = list(string)
}

variable "email" {
  description = "Email address for Let's Encrypt and Cloudflare communications"
  type        = string
}