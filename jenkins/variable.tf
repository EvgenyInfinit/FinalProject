variable "vpc_id" {
  description = "vpc_id"
  type        = string
  default     = "vpc-01b5d18890343bb2e"
}


variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
  default     = "subnet-0494136984296dfd5"
}

variable "availability_zone" {
   default = ["us-east-2a", "us-east-2b"] 
  }

# locals {
#   server_public_key = file("${path.module}/jenkins_key.pub")
# }

# variable "server_public_key" {
#   description = "Public key for the Jenkins server"
#   type        = string
#   default     = local.server_public_key
# }

# variable "servers_private_key" {
#   description = "Public key for the Jenkins server"
#   type        = string
#   default     = file("${path.module}/jenkins_key.pem")
# }


# variable "vpn_sg" {
#   description = "Security group for VPN"
#   type        = string
#   default     = "sg-0c109ecab66c28919"
# }
variable "vpn_sg" {
  description = "Security group for VPN"
  type        = list(string)
  default     = ["sg-0c109ecab66c28919", "sg-0c181c5253dcdc3e5"]
}

variable "ami" {
  description = "ami (ubuntu 18) to use - based on region"
  default = {
    "us-east-1" = "ami-00ddb0e5626798373"
    "us-east-2" = "ami-0dd9f0e7df0f0a138"
    "us-west-2" = "ami-0ac73f33a1888c64a" 
  }
}

variable "region" {
  description = "AWS region for VMs"
  default = "us-east-2"
}

variable "key_pair_names" {
  description = "EC2 Key pair names, "
  #type = list(string)
  type = string
  default = "jenkins_key"
  #default = ["consul_key", "jenkins_key", "vpn_key", "monitor_key","logging_key" ]
}


#variable "consul_security_group" {}


# variable "consul_iam_instance_profile" {}


# variable consul_join_policy_arn {}
