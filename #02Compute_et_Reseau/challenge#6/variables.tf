variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-3"
}

variable "project" {
  description = "The project name"
  type        = string
  default     = "challenge2"
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "The number of availability zones"
  type        = number
  default     = 2
}

variable "subnet_newbits" {
  description = "Additional prefix bits to create subnets from VPC CIDR"
  type        = number
  default     = 8
}

variable "name_sg_rds" {
  description = "The name for the RDS security group"
  type        = string
  default     = "web-server-sg-rds"
}

variable "name_sg_ec2" {
  description = "The name for the EC2 security group"
  type        = string
  default     = "web-server-sg-ec2"
}

variable "name_sg_alb" {
  description = "The name for the ALB security group"
  type        = string
  default     = "web-server-sg-alb"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "name_asg" {
  description = "The name for the auto scaling group"
  type        = string
  default     = "app-auto-scaling-group"
}