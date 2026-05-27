resource "aws_lambda_function" "crud_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  function_name = "items-crud-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "Items CRUD"
  }

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.crud_table.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_log]
}

resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/items-crud-lambda"
  retention_in_days = 30
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "Items CRUD"
  }
}