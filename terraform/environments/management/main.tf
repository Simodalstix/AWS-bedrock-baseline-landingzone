terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Configure your S3 backend here
    # bucket = "your-terraform-state-bucket"
    # key    = "management/terraform.tfstate"
    # region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = "management"
      Project     = "Bedrock-Baseline"
      ManagedBy   = "Terraform"
      Account     = "Management"
    }
  }
}

# Organizations setup
module "organizations" {
  source = "../../modules/organizations"

  security_account_email        = var.security_account_email
  logging_account_email         = var.logging_account_email
  shared_services_account_email = var.shared_services_account_email
  workload_account_email        = var.workload_account_email
}

# Service Control Policies
resource "aws_organizations_policy" "bedrock_governance" {
  name        = "BedrockGovernancePolicy"
  description = "SCP to govern Bedrock usage across accounts"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyBedrockOutsideApprovedRegions"
        Effect = "Deny"
        Action = [
          "bedrock:*"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.bedrock_regions
          }
        }
      },
      {
        Sid    = "DenyExpensiveBedrockModels"
        Effect = "Deny"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:*::foundation-model/anthropic.claude-3-opus*",
          "arn:aws:bedrock:*::foundation-model/anthropic.claude-v2:1*"
        ]
      }
    ]
  })
}

# Attach SCP to Workloads OU
resource "aws_organizations_policy_attachment" "bedrock_governance_workloads" {
  policy_id = aws_organizations_policy.bedrock_governance.id
  target_id = module.organizations.workloads_ou_id
}