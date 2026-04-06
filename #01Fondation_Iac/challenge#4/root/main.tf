module "static_site_dev" {
  source = "../modules/terraform-aws-static-site"
  bucket_name = "nehemie-static-site-dev-12345"

  tags = {
    Environment = "dev"
    Project = "static-site-challenge4"
  }
}

module "static_site_prod" {
  source = "../modules/terraform-aws-static-site"
  bucket_name = "nehemie-static-site-prod-12345"

  tags = {
    Environment = "prod"
    Project = "static-site-challenge4"
  }
}