# Bedrock Baseline Architecture

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Management Account                           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Organizations │  │       SCPs      │  │   Cost & Billing│ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
┌───────────────▼──┐  ┌─────────▼──────┐  ┌────▼──────────────┐
│  Security Account│  │ Logging Account│  │Infrastructure OU  │
│                  │  │                │  │                   │
│ • GuardDuty      │  │ • CloudTrail   │  │ ┌───────────────┐ │
│ • Security Hub   │  │ • VPC Flow     │  │ │Shared Services│ │
│ • Config Rules   │  │ • Log Archive  │  │ │   Account     │ │
│ • Compliance     │  │ • Retention    │  │ │               │ │
└──────────────────┘  └────────────────┘  │ │ • Bedrock     │ │
                                          │ │ • IAM Roles   │ │
┌─────────────────────────────────────────┐ │ • Monitoring  │ │
│            Workloads OU                 │ │ • Networking  │ │
│                                         │ └───────────────┘ │
│ ┌─────────────────┐ ┌─────────────────┐ └───────────────────┘
│ │ Workload Acct 1 │ │ Workload Acct 2 │
│ │                 │ │                 │
│ │ • Applications  │ │ • Applications  │
│ │ • Cross-account │ │ • Cross-account │
│ │   Bedrock access│ │   Bedrock access│
│ └─────────────────┘ └─────────────────┘
└─────────────────────────────────────────┘
```

## Key Security Features

### 1. Multi-Account Isolation
- **Security Account**: Centralized security monitoring and compliance
- **Logging Account**: Isolated audit trail and log retention
- **Shared Services**: Controlled Bedrock model access
- **Workload Accounts**: Application isolation with least privilege

### 2. Bedrock Governance
- **Model Access Control**: IAM policies restrict model usage
- **Regional Restrictions**: SCPs prevent usage outside approved regions
- **Cost Controls**: Budget alerts and usage monitoring
- **Audit Trail**: All API calls logged and monitored

### 3. Cross-Account Access Pattern
```
Workload Account → Assume Role → Shared Services Account → Bedrock API
```

## Compliance & Monitoring

### CloudTrail Integration
- All Bedrock API calls logged
- Cross-account audit trail
- Compliance reporting ready

### Cost Optimization
- Per-account cost allocation
- Model usage tracking
- Budget alerts and thresholds
- Resource tagging strategy

### Security Monitoring
- GuardDuty threat detection
- Config compliance rules
- Security Hub centralized findings
- Real-time alerting

## Deployment Benefits

### For Cloud Engineers
- **Enterprise-ready**: Production-grade security and governance
- **Scalable**: Multi-account foundation supports growth
- **Compliant**: Built-in audit and compliance features
- **Cost-effective**: Centralized resource management

### For Organizations
- **Risk Management**: Controlled AI model access
- **Cost Control**: Centralized billing and budgets
- **Governance**: Policy-driven model usage
- **Audit Ready**: Complete API call logging

## Technical Implementation

### Infrastructure as Code
- **Terraform modules**: Reusable, tested components
- **Environment separation**: Dev/staging/prod ready
- **State management**: Remote state with locking
- **CI/CD ready**: Automated deployment pipeline

### Security Best Practices
- **Least privilege IAM**: Minimal required permissions
- **External ID**: Secure cross-account access
- **Encryption**: Data in transit and at rest
- **Network isolation**: VPC-based security boundaries

This architecture provides a solid foundation for enterprise Bedrock deployments while maintaining security, compliance, and cost control.