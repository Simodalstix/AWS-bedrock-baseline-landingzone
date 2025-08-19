variable "organization_name" {
  description = "Name of the organization"
  type        = string
  default     = "bedrock-baseline"
}

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

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "Bedrock-Baseline"
    ManagedBy   = "Terraform"
    Environment = "production"
  }
}