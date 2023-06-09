
output "consul_servers" {
  value = ["${aws_instance.consul_server.*.private_ip}"]
}

#output "consul_agent" {
#  value = aws_instance.consul_agent.public_ip
#}

output "consul_server_target_group_arn" {
    value = aws_alb_target_group.consul_server.arn
}

output "aws_iam_instance_profile" {
    value = aws_iam_instance_profile.consul-join.name
}

output "consul_security_group_id" {
    value = aws_security_group.opsschool_consul.id
}

output "consul_join_policy_arn" {
    value = aws_iam_policy.consul-join.arn
}
