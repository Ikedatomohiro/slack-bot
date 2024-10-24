resource "aws_apigatewayv2_api" "ikeda_api" {
  name          = "ikeda_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.ikeda_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.pass_to_sqs_lambda.arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.ikeda_api.id
  route_key = "POST /api/rag"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.ikeda_api.id
  name        = "$default"
  auto_deploy = true
}
