variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "invocation_threshold" {
  description = "Threshold for Bedrock invocation alarms"
  type        = number
  default     = 1000
}

variable "alert_emails" {
  description = "List of email addresses for alerts"
  type        = list(string)
}

variable "monthly_budget_limit" {
  description = "Monthly budget limit for Bedrock in USD"
  type        = string
  default     = "100"
}

variable "bedrock_log_group_name" {
  description = "CloudWatch log group name for Bedrock logs"
  type        = string
}