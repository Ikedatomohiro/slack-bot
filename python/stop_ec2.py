import os
import boto3

instance_id = os.environ['INSTANCE_ID']

def lambda_handler(event, context):
    public_ip = get_instance_public_ip(instance_id)
    print(f"The public IP address of the instance {instance_id} is: {public_ip}")

    ec2 = boto3.client('ec2')
    ec2.stop_instances(InstanceIds=[instance_id])

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
