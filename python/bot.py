import json
import os
import urllib.request
from urllib.error import URLError, HTTPError
import boto3

slack_bot_token = os.environ['MAPLE_BOT_TOKEN']
dify_api_key = os.environ['MAPLE_DIFY_API_KEY']
bot_user_id = os.environ['MAPLE_BOT_USER_ID']
instance_id = os.environ['INSTANCE_ID']

def lambda_handler(event, context):
    result = extract_event_details(event)
    clean_text = result['text'].replace(f"<@{bot_user_id}>", '').strip()

    # Dify APIを使用して応答を取得
    dify_response = post_chat_message_to_dify(dify_api_key, clean_text, result['user_id'])
    answer = dify_response['data']['outputs']['text']

    # Slackのスレッドに応答を投稿
    slack_response = post_message_to_thread_to_slack(slack_bot_token, result['channel'], answer, result["thread_ts"])

    return {
        'statusCode': 200
    }

def extract_event_details(event):
    body = json.loads(event['Records'][0]['body'])
    event_data = body.get('event', {})

    result = {
        'channel': event_data.get('channel'),
        'user_id': event_data.get('user'),
        'text': event_data.get('text'),
        'thread_ts': event_data.get('thread_ts', event_data.get('ts'))
    }

    print(result)

    return result

def post_chat_message_to_dify(api_key, query, user_id, conversation_id=""):
    public_ip = get_instance_public_ip(instance_id)
    url = f'http://{public_ip}/v1/workflows/run'

    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json',
        'User-Agent': ''
    }
    data = {
        'inputs': {
            'query': query
        },
        'response_mode': 'blocking',
        'user': user_id,
        'conversation_id': conversation_id
    }

    request_data = json.dumps(data).encode('utf-8')

    print(f'request_data: {request_data}')

    request = urllib.request.Request(url, data=request_data, headers=headers, method='POST')

    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            response_data = response.read()
            print(response_data)
            return json.loads(response_data)
    except HTTPError as e:
        print(f'HTTPError: {e.code} - {e.reason}')
        error_message = e.read().decode()
        print(f'Error content: {error_message}')
    except URLError as e:
        print(f'URLError: {e.reason}')
    except Exception as e:
        print(f'Unexpected error: {e}')

# Slackのスレッドにメッセージを投稿する関数
def post_message_to_thread_to_slack(api_key, channel, text, thread_ts):
    print(text)
    url = 'https://slack.com/api/chat.postMessage'
    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json'
    }
    data = {
        'channel': channel,
        'text': text,
        'thread_ts': thread_ts
    }

    request_data = json.dumps(data).encode('utf-8')
    request = urllib.request.Request(url, data=request_data, headers=headers, method='POST')

    try:
        with urllib.request.urlopen(request) as response:
            response_data = response.read()
            return json.loads(response_data)
    except HTTPError as e:
        print(f'HTTPError: {e.code} - {e.reason}')
        print(e.read().decode())  # サーバーからのエラーメッセージを表示
    except URLError as e:
        print(f'URLError: {e.reason}')

def get_instance_public_ip(instance_id):
    ec2 = boto3.client('ec2')

    # インスタンスの詳細情報を取得
    response = ec2.describe_instances(InstanceIds=[instance_id])

    # インスタンスの情報からパブリックIPアドレスを取得
    try:
        public_ip = response['Reservations'][0]['Instances'][0]['PublicIpAddress']
        return public_ip
    except KeyError:
        return "Public IP Address not available or instance does not exist."
