variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bedrock_regions" {
  description = "List of regions where Bedrock is available"
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

variable "security_account_email" {
  description = "Email for the security account"
  type        = string
}

variable "logging_account_email" {
  description = "Email for the logging account"
  type        = string
}

variable "shared_services_account_email" {
  description = "Email for the shared services account"
  type        = string
}

variable "workload_account_email" {
  description = "Email for the workload account"
  type        = string
}