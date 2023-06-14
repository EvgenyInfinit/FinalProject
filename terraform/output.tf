output "vpc_id" {
  value = module.networking.vpcid
}


output "vpn_access_url" {
  value = module.vpn.access_vpn_url
}

output "jenkins_server" {
  value = module.jenkins.Jenkins_server
}

output "jenkins_agent" {
  value = module.jenkins.jenkins_agent
}


output "consul_servers" {
  value       = module.consul.consul_servers
}

output "elastic_server_address" {
  value = module.elastic.elastic_server_host_id
  }

output "kibana_url" {
  value = module.elastic.kibana_url
  }

  # output "monitor_server_public_ip" {
#   value = module.monitoring.monitor_server_public_ip
# }

# output "servers_key" {
#   value = module.ssh_keys.servers_key
# }

# output "k8s_cluster_id" {
#   description = "EKS cluster ID."
#   value       = module.k8s.cluster_id
# } 

# output "k8s_cluster_endpoint" {
#   description = "Endpoint for EKS control plane."
#   value       = module.k8s.cluster_endpoint
# } 

# output "k8s_oidc_provider_arn" {
#   value = module.k8s.oidc_provider_arn
# } 

# output "k8s_cluster_name" {
#   value = module.k8s.cluster_name
# } 