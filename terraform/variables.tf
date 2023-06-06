variable "region" {
  description = "AWS region for VMs"
  default = "us-east-1"
}


## ssh key variables
####################

variable "key_pair_names" {
  description = "EC2 Key pair names, "
  type = list(string)
  default = [ "jenkins_key"]
  #default = ["consul_key", "jenkins_key", "vpn_key", "monitor_key","logging_key" ]
}