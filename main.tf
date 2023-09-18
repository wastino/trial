provider "kubernetes" {
  host = data.ionoscloud_k8s_cluster.ionoscluster.server
  token =  data.ionoscloud_k8s_cluster.ionoscluster.user_tokens["cluster-admin"]
}


data "ionoscloud_k8s_cluster" "ionoscluster" {
  name = "k8s-cluster"
  depends_on = [ionoscloud_k8s_cluster.ionoscluster]
}




# Add a data source to get the kubeconfig content
# data "ionoscloud_k8s_cluster" "my_cluster" {
#   name = "trial-k8s-cluster"
#   depends_on = [ionoscloud_k8s_cluster.my_cluster]
# }







