# Bedrock Model Access Policy
resource "aws_iam_policy" "bedrock_model_access" {
  name        = "BedrockModelAccess"
  description = "Policy for controlled Bedrock model access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          for model in var.allowed_models : "arn:aws:bedrock:${var.aws_region}::foundation-model/${model}"
        ]
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = var.bedrock_regions
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:ListFoundationModels",
          "bedrock:GetFoundationModel"
        ]
        Resource = "*"
      }
    ]
  })
}

# Bedrock Admin Role for Shared Services Account
resource "aws_iam_role" "bedrock_admin" {
  name = "BedrockAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.shared_services_account_id}:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bedrock_admin_policy" {
  role       = aws_iam_role.bedrock_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

# Bedrock User Role for Workload Accounts
resource "aws_iam_role" "bedrock_user" {
  name = "BedrockUserRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = [
            for account_id in var.workload_account_ids : "arn:aws:iam::${account_id}:root"
          ]
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bedrock_user_policy" {
  role       = aws_iam_role.bedrock_user.name
  policy_arn = aws_iam_policy.bedrock_model_access.arn
}

# CloudWatch Log Group for Bedrock API calls
resource "aws_cloudwatch_log_group" "bedrock_api_logs" {
  name              = "/aws/bedrock/api-calls"
  retention_in_days = var.log_retention_days
}

# CloudTrail for Bedrock API monitoring
resource "aws_cloudtrail" "bedrock_trail" {
  name           = "bedrock-api-trail"
  s3_bucket_name = var.cloudtrail_bucket_name

  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    exclude_management_event_sources = []

    data_resource {
      type   = "AWS::Bedrock::*"
      values = ["arn:aws:bedrock:*"]
    }
  }

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.bedrock_api_logs.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_logs_role.arn
}

# IAM role for CloudTrail to write to CloudWatch Logs
resource "aws_iam_role" "cloudtrail_logs_role" {
  name = "CloudTrailLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_logs_policy" {
  name = "CloudTrailLogsPolicy"
  role = aws_iam_role.cloudtrail_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Resource = "${aws_cloudwatch_log_group.bedrock_api_logs.arn}:*"
      }
    ]
  })
}