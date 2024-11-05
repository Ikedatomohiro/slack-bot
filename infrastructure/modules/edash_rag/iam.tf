# SQS にメッセージを送信するための IAM ロール
resource "aws_iam_role" "apigateway_sqs_role" {
  name = "apigateway-sqs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# SQS へのアクセス権を付与するポリシー
resource "aws_iam_role_policy" "sqs_access_policy" {
  name = "sqs-access-policy"
  role = aws_iam_role.apigateway_sqs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sqs:SendMessage"
        Effect   = "Allow"
        Resource = aws_sqs_queue.rag_queue.arn
      }
    ]
  })
}

# Lambda実行ロール
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name = "lambda-sqs-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          # SQSにメッセージを送信するための権限
          "sqs:SendMessage",
          # SQSからメッセージを受信するための権限
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
        ],
        Effect   = "Allow",
        Resource = aws_sqs_queue.rag_queue.arn
      }
    ]
  })
}

# AWSLambdaBasicExecutionRoleをLambda実行ロールにアタッチ
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "lambda_ec2_stop_role" {
  name = "lambda-ec2-stop-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_ec2_stop_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ec2_policy" {
  role       = aws_iam_role.lambda_ec2_stop_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_policy" "edash_rag_ec2_policy" {
  name = "edash-rag-ec2-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect: "Allow",
            Action: "ec2:StopInstances",
            Resource = aws_instance.edash_rag.arn
        },
        {
            Effect: "Allow",
            Action: "ec2:DescribeInstances",
            Resource: "*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ec2_describe_attachment" {
  role       = "lambda-execution-role"
  policy_arn = aws_iam_policy.edash_rag_ec2_policy.arn
}