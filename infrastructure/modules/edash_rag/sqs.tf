# デッドレターキュー
resource "aws_sqs_queue" "rag_queue_dlq" {
  name = "rag-queue-dlq"
}

resource "aws_sqs_queue" "rag_queue" {
  name = "rag-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.rag_queue_dlq.arn
    maxReceiveCount     = 5  # 最大リトライ回数
  })
}
