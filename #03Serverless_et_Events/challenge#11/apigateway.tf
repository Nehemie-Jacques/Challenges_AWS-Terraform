resource "aws_api_gateway_rest_api" "crud_api" {
  name = "items-crud-api"
  description = "API REST for the items CRUD on DynamoDB"
}

resource "aws_api_gateway_resource" "items_resource" {
  rest_api_id = aws_api_gateway_rest_api.crud_api.id
  parent_id = aws_api_gateway_rest_api.crud_api.root_resource_id
  path_part = "items"
}

resource "aws_api_gateway_method" "items_method" {
  for_each = toset(["GET", "POST", "PUT", "DELETE"])
  rest_api_id = aws_api_gateway_rest_api.crud_api.id
  resource_id = aws_api_gateway_resource.items_resource.id
  http_method = each.value
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "lambda_integration" {
  for_each = aws_api_gateway_method.items_method
  rest_api_id = aws_api_gateway_rest_api.crud_api.id
  resource_id = aws_api_gateway_resource.items_resource.id
  http_method = each.value
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.items_lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crud_lambda.function_name
  principal     = "://amazonaws.com"

  # Restreint l'invocation à cette API Gateway spécifique pour plus de sécurité
  source_arn = "${aws_api_gateway_rest_api.crud_api.execution_arn}/*/*"
}

# 1. Déploiement de l'API avec trigger automatique de mise à jour
resource "aws_api_gateway_deployment" "crud_deployment" {
  rest_api_id = aws_api_gateway_rest_api.crud_api.id

  triggers = {
    # Force le redéploiement si les méthodes, les intégrations ou les ressources changent
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.items_resource.id,
      aws_api_gateway_method.items_methods,
      aws_api_gateway_integration.lambda_integrations,
    ]))
  }

  # Sécurité : Évite la destruction du déploiement actif avant la création du nouveau
  lifecycle {
    create_before_destroy = true
  }
}

# 2. Création du Stage "dev"
resource "aws_api_gateway_stage" "dev_stage" {
  deployment_id = aws_api_gateway_deployment.crud_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.crud_api.id
  stage_name    = "dev"
}

# 1. Génération de la clé d'API
resource "aws_api_gateway_api_key" "crud_key" {
  name        = "items-crud-api-key"
  description = "Clé d'accès pour l'API CRUD"
  enabled     = true
}

# 2. Création du plan d'utilisation (Usage Plan) associé au stage
resource "aws_api_gateway_usage_plan" "crud_usage_plan" {
  name        = "items-crud-usage-plan"
  description = "Plan de limitation et de quota pour l'environnement dev"

  api_stages {
    api_id = aws_api_gateway_rest_api.crud_api.id
    stage  = aws_api_gateway_stage.dev_stage.stage_name
  }

  # Options de protection (Free Tier amical pour éviter les abus)
  throttle_settings {
    burst_limit = 10
    rate_limit  = 5
  }
}

# 3. Association de la clé d'API au plan d'utilisation
resource "aws_api_gateway_usage_plan_key" "crud_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.crud_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.crud_usage_plan.id
}
