resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project}-${var.environment}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false # EC2 are in private subnets
    security_groups             = [aws_security_group.sg_ec2.id]
  }

  # Dependencies evaluation ensures RDS is built first to inject the endpoint
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
              echo "<p>DB Endpoint: ${aws_db_instance.main.endpoint}</p>" >> /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project}-web-instance"
    }
  }
}

resource "aws_autoscaling_group" "app_sg" {
  name                = var.name_asg
  vpc_zone_identifier = [for s in aws_subnet.private : s.id] # Must be private subnets

  min_size         = var.az_count
  max_size         = var.az_count * 2
  desired_capacity = var.az_count

  target_group_arns = [aws_lb_target_group.app.arn]
  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}