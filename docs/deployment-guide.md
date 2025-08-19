# Bedrock Baseline Architecture Deployment Guide

## Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform >= 1.0** installed
3. **Management account** with Organizations enabled
4. **Unique email addresses** for each account (5 total needed)

## Deployment Steps

### Step 1: Prepare Management Account

```bash
# Clone the repository
git clone <your-repo-url>
cd AWS-unknown

# Configure AWS CLI for management account
aws configure --profile management
```

### Step 2: Configure Terraform Backend

1. Create an S3 bucket for Terraform state:
```bash
aws s3 mb s3://your-bedrock-terraform-state --profile management
```

2. Update backend configuration in `terraform/environments/management/main.tf`

### Step 3: Configure Variables

```bash
cd terraform/environments/management
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your email addresses
```

### Step 4: Deploy Management Account

```bash
terraform init
terraform plan
terraform apply
```

### Step 5: Configure Cross-Account Access

After deployment, configure cross-account roles in each account:

1. **Security Account**: Deploy security baseline
2. **Logging Account**: Configure centralized logging
3. **Shared Services**: Deploy Bedrock resources
4. **Workload Account**: Deploy sample application

## Account-Specific Configurations

### Security Account
- AWS Config rules for compliance
- GuardDuty for threat detection
- Security Hub for centralized security

### Logging Account
- CloudTrail for API logging
- VPC Flow Logs
- Centralized log aggregation

### Shared Services Account
- Bedrock model access
- Shared networking resources
- Cost optimization tools

### Workload Account
- Application-specific resources
- Bedrock integration examples
- Monitoring and alerting

## Verification Steps

1. **Organizations Structure**:
```bash
aws organizations list-accounts
aws organizations list-organizational-units-for-parent --parent-id <root-id>
```

2. **Service Control Policies**:
```bash
aws organizations list-policies --filter SERVICE_CONTROL_POLICY
```

3. **Bedrock Access**:
```bash
aws bedrock list-foundation-models --region us-east-1
```

## Cost Optimization

- **Bedrock Usage**: Monitor model invocations and costs
- **Account Separation**: Clear cost allocation per workload
- **Resource Tagging**: Consistent tagging strategy
- **Budget Alerts**: Set up billing alerts per account

## Security Best Practices

- **Least Privilege**: IAM roles with minimal required permissions
- **Cross-Account Access**: External ID for role assumption
- **Audit Logging**: All Bedrock API calls logged
- **Compliance**: Config rules for governance

## Troubleshooting

### Common Issues

1. **Email Already in Use**: Each AWS account needs a unique email
2. **Service Limits**: Check AWS service quotas
3. **Region Availability**: Ensure Bedrock is available in chosen regions
4. **Permissions**: Management account needs Organizations full access

### Useful Commands

```bash
# Check organization status
aws organizations describe-organization

# List available Bedrock models
aws bedrock list-foundation-models --region us-east-1

# Check account status
aws organizations list-accounts
```