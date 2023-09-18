
resource "ionoscloud_datacenter" "mydc2" {
  name                = "IonosPoc DC"
  location            = var.region
  description         = "Houses a Managed Kubernetes cluster and nodepools hosting a prometeus deployment"
  sec_auth_protection = false
}

resource "ionoscloud_ipblock" "Ionos_IP" {
  location              = var.region
  size                  = 2
  name                  = "IP Block Example"
}

# resource "ionoscloud_lan" "ionospoc" {
#   datacenter_id         = ionoscloud_datacenter.mydc.id
#   public                = false
#   name                  = "IonosPoc Lan"
#   lifecycle {
#     create_before_destroy = true
#   }
# }



# Define a managed Kubernetes cluster
resource "ionoscloud_k8s_cluster" "ionoscluster" {
  name        = "k8s-cluster"
  k8s_version           = "1.27.4"
  maintenance_window {
    day_of_the_week     = "Sunday"
    time                = "09:00:00Z"
  }
}


# resource "null_resource" "wait_for_k8s" {
#   triggers = {
#     cluster_id = ionoscloud_k8s_cluster.my_cluster.id
#   }

#   provisioner "local-exec" {
#     command = "kubectl wait --for=condition=Ready node -l ionoscloud_k8s_node_pool.name=prometheusk8sNodePool --timeout=600s"
#   }
# }

resource "ionoscloud_k8s_node_pool" "prom_nodepool" {
  datacenter_id         = ionoscloud_datacenter.mydc2.id
  k8s_cluster_id        = ionoscloud_k8s_cluster.ionoscluster.id
  name                  = "k8sNodePool"
  k8s_version           = ionoscloud_k8s_cluster.ionoscluster.k8s_version
  auto_scaling {
    min_node_count      = 1
    max_node_count      = 2
  }
  cpu_family            = var.cpu_family
  availability_zone     = "AUTO"
  storage_type          = "SSD"
  node_count            = 1
  cores_count           = 4
  ram_size              = 4096
  storage_size          = 100
  public_ips            = [ ionoscloud_ipblock.IonosPoc_IP.ips[0], ionoscloud_ipblock.IonosPoc_IP.ips[1]]
#   # lans {
#     id                  = ionoscloud_lan.example.id
#     dhcp                = true
#     routes {
#        network          = "1.2.3.5/24"
#        gateway_ip       = "10.1.5.17"
#      }
#    }  
}

resource "kubernetes_namespace" "monitoring" {
  depends_on = [ ionoscloud_k8s_node_pool.prom_nodepool ]
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  depends_on = [kubernetes_namespace.monitoring]
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.id
  version    = "45.7.1"


  set {
    name  = "prometheusOperator.createCustomResource"
    value = "true"
  }
}


# resource "kubernetes_config_map" "prometheus_config" {
#   metadata {
#     name      = "prometheus-config"
#     namespace = "prometheus"
#   }
#     data = {
#     "prometheus.yml" = <<-EOT
#       global:
#         scrape_interval: 15s
#       scrape_configs:
#         - job_name: 'ionos_website'
#           metrics_path: /metrics
#           static_configs:
#             - targets: ['mail.ionos.com:80']
#     EOT
#   }
# }

resource "helm_release" "blackbox_exporter" {
  depends_on = [helm_release.prometheus]
  name       = "blackbox-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-blackbox-exporter"
  version    = "8.0.0"  
  namespace  = "prometheus"
  
  values = [
    data.http.blackbox_operator_values.body,  
  ]
}

data "http" "blackbox_operator_values" {
  url = "https://github.com/wastino/trial/blob/main/blackbox.yaml"
}

