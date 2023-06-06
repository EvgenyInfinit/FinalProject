
module "ssh_keys" {
  source   = "./modules/ssh_keys"
  key_pair = var.key_pair_names
}

module "networking" {
  source    = "./modules/network"
  region = var.region
  #consul_target_group_arn = module.consul.consul-server-target-group-arn
  #jenkins_target_group_arn = module.jenkins.jenkins-server-target-group-arn
  #elastic_target_group_arn = module.elastic.elastic_target_group_arn
 } 

# module "jenkins" {
#   source    = "./modules/jenkins"
#   vpc_id = module.networking.vpcid
#   # vpn_sg = module.vpn.vpn_sg
#   # server_public_key = module.ssh_keys.servers_key[1]
#   # servers_private_key = module.ssh_keys.servers_private_key[1]
#   # subnet_id = module.networking.private-subnet-id
#   # availability_zone = var.availability_zone
#   # ami = var.ami
#   region = var.region
#   # consul_iam_instance_profile = module.consul.aws_iam_instance_profile
#   # consul_security_group = module.consul.consul_security_group_id
#   # consul_join_policy_arn= module.consul.consul_join_policy_arn
# } 



# module "k8s" {
#   source    = "./modules/k8s"
#   vpc_id = module.networking.vpcid
#   region = var.region
#   subnet_ids = module.networking.private_subnet_id
#   #role_arn  = module.jenkins.jenkins_role_arn
#   #role_name = module.jenkins.jenkins_role_name
# }

# module "monitoring" {
#   source    = "./modules/monitor"
#   # region = var.region
#   vpc_id = module.networking.vpcid
#   subnet_id = module.networking.public-subnet-id[0]
#   server_public_key = module.ssh_keys.servers_key[0]
#  } 