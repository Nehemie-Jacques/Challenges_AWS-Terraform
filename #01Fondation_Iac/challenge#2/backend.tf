terraform {
  backend "s3" {
    bucket         = "bucket-bootstrap-challenge1"
    key            = "challenge-02/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}