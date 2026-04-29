resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name
}

# Configuration de l'accès public au bucket S3 : Bloquer l'accès public
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Dépôt de l'objet index.html dans le bucket S3
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}

# Politique IAM pour autoriser l'accès depuis CloudFront via OAC
data "aws_iam_policy_document" "allow_cloudfront" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket     = aws_s3_bucket.site.id
  policy     = data.aws_iam_policy_document.allow_cloudfront.json
  depends_on = [aws_cloudfront_distribution.s3_distribution]
}