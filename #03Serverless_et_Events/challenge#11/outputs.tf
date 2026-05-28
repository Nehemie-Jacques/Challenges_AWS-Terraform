output "api_url" {
  description = "URL finale et sécurisée de votre API"
  value       = "${aws_api_gateway_stage.dev_stage.invoke_url}/items"
}

output "api_key_value" {
  description = "Valeur de la clé d'API (À passer dans le header X-API-Key)"
  value       = aws_api_gateway_api_key.crud_key.value
  sensitive   = true
}
