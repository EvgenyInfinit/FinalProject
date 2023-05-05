# variable "aws_region" {
#  default =  "us-east-1" 
#  description = "aws region"
# }

variable "region" {}
variable "vpc_id" {}
variable "subnet_ids" {}
#variable "role_arn" { }
#variable "role_name" { }



variable "kubernetes_version" {
  default = 1.24
  description = "kubernetes version"
}

locals {
  k8s_service_account_namespace = "default" ## need to change ???!!!!
  k8s_service_account_name      = "opsschool-sa"
}

variable "tag_enviroment" {
  description = "Describe the enviroment"
  default = "kandula_evgy"
}

variable "project_name" {
  type = string
  default = "kandula_evgy"
}

variable "eks_cluster_name" {
  default = "final-project-eks-cluster"
}

# locals {
#   cluster_name = "opsschool-eks-${random_string.suffix.result}"
# }


