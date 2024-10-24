import json
import os
import boto3

sqs = boto3.client('sqs')

def lambda_handler(event, context):
    body = json.loads(event['body'])

    # リクエストのタイプがURL検証（url_verification）の場合は、チャレンジ（Challenge）を返す
    if body.get('type') == 'url_verification':
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'text/plain'
            },
            'body': body['challenge']
        }

    # SQSにメッセージを送信
    response = sqs.send_message(
        QueueUrl=os.environ['SQS_URL'],
        MessageBody=json.dumps(body)
    )

    if response['ResponseMetadata']['HTTPStatusCode'] != 200:
        print('Failed to send message to SQS')
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Failed to send message to SQS'})
        }

    print('Message sent to SQS')
    print(body)
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Message sent to SQS', 'MessageId': response['MessageId']})
    }
