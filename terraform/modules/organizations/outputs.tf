output "organization_id" {
  description = "The organization ID"
  value       = aws_organizations_organization.main.id
}

output "organization_arn" {
  description = "The organization ARN"
  value       = aws_organizations_organization.main.arn
}

output "security_account_id" {
  description = "Security account ID"
  value       = aws_organizations_account.security.id
}

output "logging_account_id" {
  description = "Logging account ID"
  value       = aws_organizations_account.logging.id
}

output "shared_services_account_id" {
  description = "Shared services account ID"
  value       = aws_organizations_account.shared_services.id
}

output "workload_account_id" {
  description = "Workload account ID"
  value       = aws_organizations_account.workload.id
}

output "workloads_ou_id" {
  description = "Workloads OU ID"
  value       = aws_organizations_organizational_unit.workloads.id
}