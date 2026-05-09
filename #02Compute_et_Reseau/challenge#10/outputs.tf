output "app_instance_id" {
  value = aws_instance.app.id
}

output "tools_instance_private_ip" {
  value = aws_instance.tools.private_ip
}