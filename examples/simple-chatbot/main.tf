# Example: Simple Bedrock Chatbot using the Baseline Architecture
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Lambda function for chatbot
resource "aws_lambda_function" "chatbot" {
  filename         = "chatbot.zip"
  function_name    = "bedrock-chatbot"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.11"
  timeout         = 30

  environment {
    variables = {
      BEDROCK_REGION = var.aws_region
      MODEL_ID       = "anthropic.claude-3-haiku-20240307-v1:0"
    }
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "bedrock-chatbot-lambda-role"

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

# Policy to assume Bedrock role in shared services account
resource "aws_iam_role_policy" "lambda_bedrock_policy" {
  name = "lambda-bedrock-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Resource = "arn:aws:iam::${var.shared_services_account_id}:role/BedrockUserRole"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# API Gateway for HTTP interface
resource "aws_apigatewayv2_api" "chatbot_api" {
  name          = "bedrock-chatbot-api"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_credentials = false
    allow_headers     = ["content-type"]
    allow_methods     = ["POST", "GET", "OPTIONS"]
    allow_origins     = ["*"]
    max_age          = 86400
  }
}