resource "aws_apigatewayv2_api" "edash_rag_api" {
  name          = "edash-rag-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "edash_rag_integration" {
  api_id                 = aws_apigatewayv2_api.edash_rag_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.pass_to_sqs_lambda.arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "edash_rag_route" {
  api_id    = aws_apigatewayv2_api.edash_rag_api.id
  route_key = "POST /api/rag"
  target    = "integrations/${aws_apigatewayv2_integration.edash_rag_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.edash_rag_api.id
  name        = "$default"
  auto_deploy = true
}
