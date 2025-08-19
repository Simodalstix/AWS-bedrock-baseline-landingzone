# Bedrock Baseline Architecture Makefile

.PHONY: help init plan apply destroy validate clean

# Default target
help:
	@echo "Available targets:"
	@echo "  init      - Initialize Terraform"
	@echo "  validate  - Validate Terraform configuration"
	@echo "  plan      - Plan Terraform deployment"
	@echo "  apply     - Apply Terraform configuration"
	@echo "  destroy   - Destroy infrastructure"
	@echo "  clean     - Clean Terraform files"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	cd terraform/environments/management && terraform init

# Validate configuration
validate:
	@echo "Validating Terraform configuration..."
	cd terraform/environments/management && terraform validate

# Plan deployment
plan:
	@echo "Planning Terraform deployment..."
	cd terraform/environments/management && terraform plan

# Apply configuration
apply:
	@echo "Applying Terraform configuration..."
	cd terraform/environments/management && terraform apply

# Destroy infrastructure
destroy:
	@echo "Destroying infrastructure..."
	cd terraform/environments/management && terraform destroy

# Clean Terraform files
clean:
	@echo "Cleaning Terraform files..."
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name "terraform.tfstate*" -delete
	find . -name ".terraform.lock.hcl" -delete