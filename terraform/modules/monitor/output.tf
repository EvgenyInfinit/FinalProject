output "monitor_server_public_ip" {
  value = join(",", aws_instance.monitor.*.public_ip)
}