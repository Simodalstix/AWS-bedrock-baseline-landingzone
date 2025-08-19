resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "securityhub.amazonaws.com",
    "sso.amazonaws.com",
    "bedrock.amazonaws.com"
  ]

  feature_set = "ALL"

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
}

# Security OU
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.main.roots[0].id
}

# Workloads OU
resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = aws_organizations_organization.main.roots[0].id
}

# Infrastructure OU
resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = aws_organizations_organization.main.roots[0].id
}

# Security Account
resource "aws_organizations_account" "security" {
  name  = "Security Account"
  email = var.security_account_email
  
  parent_id = aws_organizations_organizational_unit.security.id
}

# Logging Account
resource "aws_organizations_account" "logging" {
  name  = "Logging Account"
  email = var.logging_account_email
  
  parent_id = aws_organizations_organizational_unit.infrastructure.id
}

# Shared Services Account
resource "aws_organizations_account" "shared_services" {
  name  = "Shared Services Account"
  email = var.shared_services_account_email
  
  parent_id = aws_organizations_organizational_unit.infrastructure.id
}

# Workload Account
resource "aws_organizations_account" "workload" {
  name  = "Workload Account"
  email = var.workload_account_email
  
  parent_id = aws_organizations_organizational_unit.workloads.id
}