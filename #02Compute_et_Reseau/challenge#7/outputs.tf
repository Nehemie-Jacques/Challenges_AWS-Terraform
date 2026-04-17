output "instance_id" {
  description = "ID of the EC2 Instance to connect via SSM"
  value       = aws_instance.ssm_server.id
}