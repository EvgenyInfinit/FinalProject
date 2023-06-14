variable "availability_zone" {}

variable "vpc_id" {}

variable "server_public_key" {}

variable "servers_private_key" {}

variable "subnet_id" {}

variable "vpn_sg" {}

variable "region" {}

variable "ami" {}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet" {
  default = "10.0.4.0/24"
}


