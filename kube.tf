module "kube-hetzner" {
  providers = {
    hcloud = hcloud
  }

  # https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner/blob/master/kube.tf.example

  hcloud_token = var.hcloud_token

  source = "kube-hetzner/kube-hetzner/hcloud"
  # version = "2.11.7"

  ssh_port        = 2220
  ssh_public_key  = file("./id_ed25519_terraform_hetzner_cloudb.pub")
  ssh_private_key = file("./id_ed25519_terraform_hetzner_cloudb")

  network_region = "eu-central"

  control_plane_nodepools = [
    {
      name        = "control-plane",
      server_type = "cax11",
      location    = "fsn1",
      labels      = [],
      taints      = [],
      count       = 3
    }
  ]

  agent_nodepools = [
    {
      name        = "agent-1",
      server_type = "cx22",
      location    = "fsn1",
      labels = [
        "run=application",
      ],
      taints = [],
      count  = 1,
    },
    {
      name        = "agent-2",
      server_type = "cx22",
      location    = "fsn1",
      labels = [
        "run=packages",
        "node.longhorn.io/create-default-disk=true"
      ],
      taints = [],
      count  = 1,
    },
    {
      name        = "agent-3",
      server_type = "cx22",
      location    = "fsn1",
      labels = [
        "node.kubernetes.io/server-usage=storage",
        "node.longhorn.io/create-default-disk=true"
      ],
      taints               = [],
      count                = 1,
      longhorn_volume_size = 0
    }
  ]

  load_balancer_type     = "lb11"
  load_balancer_location = "fsn1"
  traefik_additional_options = [
    "--providers.kubernetescrd.allowCrossNamespace=true",
    "--providers.kubernetesingress.allowCrossNamespace=true"
  ]
  dns_servers = [
    "1.1.1.1",
    "8.8.8.8",
    "2606:4700:4700::1111",
  ]

  microos_x86_snapshot_id = var.microos_x86_snapshot_id
  microos_arm_snapshot_id = var.microos_arm_snapshot_id

  create_kubeconfig = true
  export_values     = true

  extra_firewall_rules = [
    # {
    #   description     = "For Postgres"
    #   direction       = "in"
    #   protocol        = "tcp"
    #   port            = "5432"
    #   source_ips      = ["0.0.0.0/0", "::/0"]
    #   destination_ips = [] # Won't be used for this rule
    # },
    {
      description     = "To Allow ArgoCD access to resources via SSH"
      direction       = "out"
      protocol        = "tcp"
      port            = "22"
      source_ips      = [] # Won't be used for this rule
      destination_ips = ["0.0.0.0/0", "::/0"]
    },
    {
      description     = "Allow CIFS/SMB access"
      direction       = "in"
      protocol        = "tcp"
      port            = "445"
      source_ips      = ["0.0.0.0/0", "::/0"] # Adjust this based on your security needs
      destination_ips = [] # Won't be used for this rule
    },
    {
      description     = "Allow CIFS/SMB access"
      direction       = "out"
      protocol        = "tcp"
      port            = "445"
      source_ips      = [] # Adjust this based on your security needs
      destination_ips = ["0.0.0.0/0", "::/0"] # Won't be used for this rule
    },
    {
      description     = "Allow CIFS/SMB access (legacy)"
      direction       = "in"
      protocol        = "tcp"
      port            = "139"
      source_ips      = ["0.0.0.0/0", "::/0"] # Adjust this based on your security needs
      destination_ips = [] # Won't be used for this rule
    },
    {
      description     = "Allow NetBIOS Name Service"
      direction       = "in"
      protocol        = "udp"
      port            = "137"
      source_ips      = ["0.0.0.0/0", "::/0"] # Adjust this based on your security needs
      destination_ips = [] # Won't be used for this rule
    },
    {
      description     = "Allow NetBIOS Datagram Service"
      direction       = "in"
      protocol        = "udp"
      port            = "138"
      source_ips      = ["0.0.0.0/0", "::/0"] # Adjust this based on your security needs
      destination_ips = [] # Won't be used for this rule
    }
  ]

  enable_longhorn        = true
  longhorn_replica_count = 2

  longhorn_values = <<EOT
defaultSettings:
  createDefaultDiskLabeledNodes: true
  defaultDataPath: /var/longhorn
  node-down-pod-deletion-policy: delete-both-statefulset-and-deployment-pod
persistence:
  defaultFsType: ext4
  defaultClassReplicaCount: 1
  defaultClass: true
  reclaimPolicy: Retain
  EOT
}

output "kubeconfig" {
  value     = module.kube-hetzner.kubeconfig
  sensitive = true
}

resource "kubernetes_secret" "cifs_secret" {
  metadata {
    name      = "cifs-secret"
    namespace = "longhorn-system"
  }

  type = "Opaque"

  data = {
    CIFS_USERNAME = var.cifs_username
    CIFS_PASSWORD = var.cifs_password
  }
}