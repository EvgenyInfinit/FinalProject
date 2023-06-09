variable "region" {}
variable "vpc_id" {}
variable "subnet_ids" {}
variable "role_arn" { }
variable "role_name" { }



variable "kubernetes_version" {
  default = 1.24
  description = "kubernetes version"
}

locals {
  k8s_service_account_namespace = "default"
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
  default = "f-project-eks-cluster-2"
}


