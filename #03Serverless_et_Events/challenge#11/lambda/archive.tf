# Déclaration du fournisseur de données pour l'archivage
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/handler.py"
  output_path = "${path.module}/.terraform/tmp/lambda_function.zip"
}
