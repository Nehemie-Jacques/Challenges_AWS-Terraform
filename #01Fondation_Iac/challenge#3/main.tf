data "aws_caller_identity" "current" {}

locals {
  computed_bucket_name = "${var.name_prefix}-${var.environment}-${data.aws_caller_identity.current.account_id}"
  bucket_name = var.bucket_name_override != null ? var.bucket_name_override : local.computed_bucket_name

  dynamodb_table_name = "${var.name_prefix}-${var.environment}-locks"

  common_tags = merge(
    {
      name = "${var.name_prefix}-${var.environment}"
      Environment = var.environment
      Project = var.name_prefix
      ManagedBy = "Terraform"
    }, 
    var.tags
  )
}

resource "aws_s3_bucket" "state" {
  bucket = local.bucket_name
  tags = local.common_tags
}

resource "aws_dynamodb_table" "lock" {
 name = local.dynamodb_table_name
 billing_mode = "PAY_PER_REQUEST" 
 hash_key = "LockID"

 attribute {
   name = "LockID"
   type = "S"
 }

 tags = local.common_tags
}