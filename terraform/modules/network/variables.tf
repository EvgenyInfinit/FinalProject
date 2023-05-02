variable "region" {
  description = "AWS region for VMs"
  /* default = "us-east-1" */
}

variable "public_subnet" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24"]
  }

variable "private_subnet" {
  type    = list(string)
  default = ["10.0.6.0/24", "10.0.7.0/24"]
  }

variable "ingressrules" {
  type    = list(number)
  default = [80, 443, 22]
}

#variable "consul_target_group_arn" {}

#variable "jenkins_target_group_arn" {}

#variable "elastic_target_group_arn" {}