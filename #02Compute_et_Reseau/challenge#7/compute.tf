resource "aws_instance" "ssm_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  vpc_security_group_ids = [aws_security_group.ssm_sg.id]

  tags = {
    Name = "${var.project}-${var.environment}-ssm-server"
  }
}