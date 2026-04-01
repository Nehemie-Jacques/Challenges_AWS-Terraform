terraform {
  backend "s3" {
    bucket         = "bucket-bootstrap-challenge1"
    key            = "./terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}