# Prometheus
module "prometheus" {
  providers = {
    helm = helm
  }

  source = "./module/prometheus"
  count  = 1
  tags = {
    Name       = "Prometheus"
    Created_by = "terraform"
  }

  prometheus_storageclass_name = var.prometheus_storageclass_name
  prometheus_storage_size      = var.prometheus_storage_size
  prometheus_retention_period  = var.prometheus_retention_period
  
  values_file = "values/prometheus-default-values"

  depends_on = [module.kube-hetzner]
}
