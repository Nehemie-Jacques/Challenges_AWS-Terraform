resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name
  tags   = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_instance" "import" {
  instance_type = var.instance_type
  ami           = var.ami_id
  tags          = var.tags

  lifecycle {
    ignore_changes = [
      security_groups,
      vpc_security_group_ids,
      user_data,
      metadata_options
    ]
  }
}