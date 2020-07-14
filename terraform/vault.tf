# provider helm {
#   kubernetes {
#     host     = "https://104.196.242.174"
#     username = "ClusterMaster"
#     password = "MindTheGap"

#     client_certificate     = file("~/.kube/client-cert.pem")
#     client_key             = file("~/.kube/client-key.pem")
#     cluster_ca_certificate = file("~/.kube/cluster-ca-cert.pem")
#   }
# }

# resource helm_release myvault {
#   name  = "myvault"
#   chart = "hashicorp/vault-helm"

#   set {
#     name  = "ingress.enabled"
#     value = true
#   }

#   set {
#     name  = "service.type"
#     value = "NodePort"
#   }
# }