output "app_instance_id" {
  value = aws_instance.app_instance.id
}

output "tools_instance_private_ip" {
  value = aws_instance.tools_instance.private_ip
}