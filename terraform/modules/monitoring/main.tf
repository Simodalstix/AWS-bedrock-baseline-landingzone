# CloudWatch Dashboard for Bedrock Monitoring
resource "aws_cloudwatch_dashboard" "bedrock_dashboard" {
  dashboard_name = "Bedrock-Baseline-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Bedrock", "Invocations", "ModelId", "anthropic.claude-3-sonnet-20240229-v1:0"],
            [".", ".", ".", "anthropic.claude-3-haiku-20240307-v1:0"],
            [".", ".", ".", "amazon.titan-text-express-v1"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Bedrock Model Invocations"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Bedrock", "InputTokenCount", "ModelId", "anthropic.claude-3-sonnet-20240229-v1:0"],
            [".", "OutputTokenCount", ".", "."],
            [".", "InputTokenCount", ".", "anthropic.claude-3-haiku-20240307-v1:0"],
            [".", "OutputTokenCount", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Token Usage"
          period  = 300
        }
      }
    ]
  })
}

# CloudWatch Alarms for Cost Control
resource "aws_cloudwatch_metric_alarm" "high_bedrock_usage" {
  alarm_name          = "bedrock-high-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Invocations"
  namespace           = "AWS/Bedrock"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.invocation_threshold
  alarm_description   = "This metric monitors Bedrock invocations"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ModelId = "anthropic.claude-3-sonnet-20240229-v1:0"
  }
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "bedrock-alerts"
}

resource "aws_sns_topic_subscription" "email_alerts" {
  count     = length(var.alert_emails)
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_emails[count.index]
}

# Cost Budget for Bedrock
resource "aws_budgets_budget" "bedrock_budget" {
  name         = "bedrock-monthly-budget"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  time_period_start = "2024-01-01_00:00"

  cost_filter {
    dimension {
      key           = "Service"
      values        = ["Amazon Bedrock"]
      match_options = ["EQUALS"]
    }
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.alert_emails
  }
}

# Custom Metric for Model Usage Tracking
resource "aws_cloudwatch_log_metric_filter" "bedrock_model_usage" {
  name           = "BedrockModelUsage"
  log_group_name = var.bedrock_log_group_name
  pattern        = "[timestamp, request_id, event_name=\"InvokeModel\", ...]"

  metric_transformation {
    name      = "BedrockModelInvocations"
    namespace = "Custom/Bedrock"
    value     = "1"
  }
}