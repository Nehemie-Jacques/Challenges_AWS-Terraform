data "aws_acm_certificate" "my_domain" {
  region   = var.region
  domain   = "*.${local.my_domain}"
  statuses = ["ISSUED"]
}