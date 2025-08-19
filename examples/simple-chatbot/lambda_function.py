import json
import boto3
import os
from botocore.exceptions import ClientError

def handler(event, context):
    """
    Lambda function to handle chatbot requests using Bedrock
    """
    
    # Parse the request
    try:
        body = json.loads(event['body'])
        user_message = body.get('message', '')
    except:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid request format'})
        }
    
    if not user_message:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Message is required'})
        }
    
    try:
        # Assume role in shared services account
        sts_client = boto3.client('sts')
        assumed_role = sts_client.assume_role(
            RoleArn=f"arn:aws:iam::{os.environ['SHARED_SERVICES_ACCOUNT_ID']}:role/BedrockUserRole",
            RoleSessionName='chatbot-session',
            ExternalId=os.environ['EXTERNAL_ID']
        )
        
        # Create Bedrock client with assumed role credentials
        bedrock_client = boto3.client(
            'bedrock-runtime',
            region_name=os.environ['BEDROCK_REGION'],
            aws_access_key_id=assumed_role['Credentials']['AccessKeyId'],
            aws_secret_access_key=assumed_role['Credentials']['SecretAccessKey'],
            aws_session_token=assumed_role['Credentials']['SessionToken']
        )
        
        # Prepare the request for Claude
        request_body = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 1000,
            "messages": [
                {
                    "role": "user",
                    "content": user_message
                }
            ]
        }
        
        # Invoke Bedrock model
        response = bedrock_client.invoke_model(
            modelId=os.environ['MODEL_ID'],
            body=json.dumps(request_body),
            contentType='application/json'
        )
        
        # Parse response
        response_body = json.loads(response['body'].read())
        ai_response = response_body['content'][0]['text']
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'response': ai_response,
                'model': os.environ['MODEL_ID']
            })
        }
        
    except ClientError as e:
        print(f"AWS Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to process request'})
        }
    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }