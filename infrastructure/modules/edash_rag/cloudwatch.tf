resource "aws_cloudwatch_event_rule" "stop_ec2_rule" {
  name                = "StopEC2DailyRule"
  description         = "Stop EC2 instance every day at 22:00(JST)"
  schedule_expression = "cron(00 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.stop_ec2_rule.name
  target_id = "StopEC2Lambda"
  arn       = aws_lambda_function.stop_ec2.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_ec2_rule.arn
}

resource "aws_cloudwatch_log_group" "stop_ec2_lambda_log_group" {
  name              = "/aws/lambda/stop_ec2"
  retention_in_days = var.cloudwatch_log_retention
}

resource "aws_cloudwatch_log_group" "post_rag_response_to_slack_function_lambda_log_group" {
  name              = "/aws/lambda/post-rag-response-to-slack-function"
  retention_in_days = var.cloudwatch_log_retention
}

resource "aws_cloudwatch_log_group" "pass_to_sqs_lambda_log_group" {
  name              = "/aws/lambda/pass_to_sqs_lambda"
  retention_in_days = var.cloudwatch_log_retention
}
