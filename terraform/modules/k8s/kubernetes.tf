# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint  #data.aws_eks_cluster.eks.endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data) #data.aws_eks_cluster.eks.certificate_authority[0].data)
#   #token                  = data.aws_eks_cluster_auth.eks.token
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }

resource "kubernetes_service_account" "opsschool_sa" {
  depends_on = [module.eks] 
  metadata {
    name      = local.k8s_service_account_name
    namespace = local.k8s_service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_iam-assumable-role-with-oidc.iam_role_arn
    }
  }
}