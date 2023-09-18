terraform {
  required_providers {
    ionoscloud = {
      source = "ionos-cloud/ionoscloud"
      version = "6.4.8"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.11.0"
    }

    kubernetes = {
        source = "hashicorp/kubernetes"
        version = ">=2.16.1"
    }
  }
}

provider "ionoscloud" {
  username = "sme20230818_cloud_nw@itohm.de"
  password = "#h9!s;Y;b#"
}

# provider "kubernetes" {
#   config_path    = "~/.kube/ionosconfig"
#   config_context = "cluster-admin@k8s-cluster"
# }




