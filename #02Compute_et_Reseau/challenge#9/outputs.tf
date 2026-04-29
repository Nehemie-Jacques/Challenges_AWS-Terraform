output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"   
}

output "s3_bucket_name" {
  value = aws_s3_bucket.site.id
}