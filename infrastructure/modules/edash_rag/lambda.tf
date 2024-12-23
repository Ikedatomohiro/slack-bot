# Slackからの通知をSQSに渡すLambda
resource "aws_lambda_function" "pass_to_sqs_lambda" {
  function_name    = "pass_to_sqs_lambda"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "pass_to_sqs.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.function_pass_to_sqs_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.function_pass_to_sqs_zip.output_path)

  environment {
    variables = {
      SQS_URL = aws_sqs_queue.rag_queue.url
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.edash_rag_private_subnet.id]
    security_group_ids = [aws_security_group.edash_rag_sg.id]
  }
}

data "archive_file" "function_pass_to_sqs_zip" {
  type        = "zip"
  source_file = "../python/pass_to_sqs.py"
  output_path = "../python/function_pass_to_sqs.zip"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pass_to_sqs_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.edash_rag_api.execution_arn}/*/*"
}

# SQS から Lambda をトリガー
resource "aws_lambda_function" "post_rag_response_to_slack_function" {
  function_name    = "post-rag-response-to-slack-function"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "bot.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.function_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.function_zip.output_path)
  timeout          = 30

  environment {
    variables = var.edash_rag_envs
  }

  tags = {
    Name = "post-rag-response-to-slack-function"
  }
}

data "archive_file" "function_zip" {
  type        = "zip"
  source_file = "../python/bot.py"
  output_path = "../python/function.zip"
}

# Lambda に SQS キューからのアクセスを許可するポリシー
resource "aws_lambda_permission" "sqs_lambda_permission" {
  statement_id  = "AllowSQSTrigger"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_rag_response_to_slack_function.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.rag_queue.arn
}

# SQS キューから Lambda をトリガー
resource "aws_lambda_event_source_mapping" "sqs_lambda" {
  event_source_arn = aws_sqs_queue.rag_queue.arn
  function_name    = aws_lambda_function.post_rag_response_to_slack_function.arn
  batch_size       = 10
  enabled          = true
}

# Dify用EC2をストップするLambda
resource "aws_lambda_function" "stop_ec2" {
  function_name    = "stop_ec2"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "stop_ec2.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.function_stop_ec2_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.function_stop_ec2_zip.output_path)

  environment {
    variables = {
      INSTANCE_ID = var.edash_rag_envs.INSTANCE_ID
    }
  }

  timeout = 20
}

data "archive_file" "function_stop_ec2_zip" {
  type        = "zip"
  source_file = "../python/stop_ec2.py"
  output_path = "../python/function_stop_ec2.zip"
}
