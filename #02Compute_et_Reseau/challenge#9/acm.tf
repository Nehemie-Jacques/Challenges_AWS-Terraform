# data "aws_acm_certificate" "my_domain" {
#   region   = var.aws_region_east
#   domain   = "*.${local.my_domain}"
#   statuses = ["ISSUED"]
# }