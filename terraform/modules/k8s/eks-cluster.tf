module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.10.0"
  cluster_name    = var.eks_cluster_name #local.cluster_name 
  cluster_version = var.kubernetes_version
  subnet_ids      = var.subnet_ids # module.vpc.public_subnets #data.aws_subnets.private_subnets.ids
  #cluster_endpoint_private_access = false 
  #cluster_endpoint_public_access = true 

  enable_irsa = true
  
  #kms_key_aliases = ["evgy-uri"]
  #create_kms_key = false
  tags = {
    Name = "eks-cluster-${var.project_name}"
    env = var.tag_enviroment
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }
  vpc_id = var.vpc_id   #module.vpc.vpc_id #data.aws_vpc.vpc.id
  
  eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      instance_types         = ["t3.medium"]
      vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {
    
    group_1 = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
      instance_types = ["t3.medium"]
    }

    group_2 = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
      instance_types = ["t3.medium"]

    }
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

# module "iam_assumable_role_admin" {
#   source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version                       = "~> 4.7.0"
#   create_role                   = true
#   role_name                     = "opsschool-role"
#   provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
#   role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
#   oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
#   depends_on = [module.eks]
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.eks.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.eks.token
# }

# # add Jenkins IAM role to EKS cluster

locals {
map_roles = [
    {
      rolearn  = var.role_arn
      username = var.role_name
      groups   = ["system:masters"]
    },
  ]
}

module "eks_auth" {
  source                   = "aidanmelen/eks-auth/aws"
  version                  = "1.0.0"
  eks                      = module.eks
  wait_for_cluster_timeout = 300
  map_roles                = local.map_roles
  map_users = [
    {
      userarn  = "arn:aws:iam::015098999341:user/evgy"
      username = "evgy"
      groups   = ["system:masters"]
    },
    ]
  depends_on = [module.eks]
}