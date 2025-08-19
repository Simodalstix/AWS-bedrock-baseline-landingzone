variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "bedrock_regions" {
  description = "List of regions where Bedrock is available"
  type        = list(string)
}

variable "allowed_models" {
  description = "List of allowed Bedrock models"
  type        = list(string)
  default = [
    "anthropic.claude-3-sonnet-20240229-v1:0",
    "anthropic.claude-3-haiku-20240307-v1:0",
    "amazon.titan-text-express-v1",
    "amazon.titan-embed-text-v1"
  ]
}

variable "shared_services_account_id" {
  description = "Shared services account ID"
  type        = string
}

variable "workload_account_ids" {
  description = "List of workload account IDs"
  type        = list(string)
}

variable "external_id" {
  description = "External ID for cross-account role assumption"
  type        = string
  sensitive   = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}