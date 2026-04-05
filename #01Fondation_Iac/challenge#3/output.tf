output "s3_bucket_name" {
  description = "Name of the S3 bucket created for this environment"
  value       = aws_s3_bucket.state.bucket
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table created for state locking"
  value       = aws_dynamodb_table.lock.name
}

output "environment" {
  description = "Current deployment environment"
  value       = var.environment
}
