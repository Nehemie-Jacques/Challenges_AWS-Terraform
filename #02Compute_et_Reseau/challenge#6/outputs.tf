output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "rds_endpoint" {
  description = "The database endpoint"
  value       = aws_db_instance.main.endpoint
}

output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_sg.name
}