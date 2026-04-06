output "ARN_bucket" {
    description = "The ARN of the S3 bucket"
  value = aws_s3_bucket.state.arn
}

output "bucket_name" {
    description = "The name of the S3 bucket"
  value = aws_s3_bucket.state.bucket
}

output "url_web_site" {
  description = ""
  value = 
}