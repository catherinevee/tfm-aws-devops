# Makefile for AWS DevOps Pipeline Terraform Module

.PHONY: help init plan apply destroy validate fmt lint clean test

# Default target
help:
	@echo "Available commands:"
	@echo "  init     - Initialize Terraform"
	@echo "  plan     - Show Terraform plan"
	@echo "  apply    - Apply Terraform configuration"
	@echo "  destroy  - Destroy Terraform resources"
	@echo "  validate - Validate Terraform configuration"
	@echo "  fmt      - Format Terraform code"
	@echo "  lint     - Lint Terraform code"
	@echo "  clean    - Clean up temporary files"
	@echo "  test     - Run tests"

# Initialize Terraform
init:
	terraform init

# Show Terraform plan
plan:
	terraform plan

# Apply Terraform configuration
apply:
	terraform apply

# Destroy Terraform resources
destroy:
	terraform destroy

# Validate Terraform configuration
validate:
	terraform validate

# Format Terraform code
fmt:
	terraform fmt -recursive

# Lint Terraform code (requires tflint)
lint:
	@if command -v tflint >/dev/null 2>&1; then \
		tflint --init; \
		tflint; \
	else \
		echo "tflint not found. Install with: go install github.com/terraform-linters/tflint/cmd/tflint@latest"; \
	fi

# Clean up temporary files
clean:
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*
	rm -f .tflint.hcl

# Run tests (requires terratest)
test:
	@if command -v go >/dev/null 2>&1; then \
		cd test && go test -v -timeout 30m; \
	else \
		echo "Go not found. Install Go to run tests."; \
	fi

# Check for security issues (requires terrascan)
security-scan:
	@if command -v terrascan >/dev/null 2>&1; then \
		terrascan scan; \
	else \
		echo "terrascan not found. Install with: curl -L \"\$$(curl -s https://api.github.com/repos/accurics/terrascan/releases/latest | grep -o -E 'https://github.com/accurics/terrascan/releases/download/v[0-9]+\.[0-9]+\.[0-9]+/terrascan_[0-9]+\.[0-9]+\.[0-9]+_Linux_x86_64.tar.gz')\" | tar -xz terrascan && sudo mv terrascan /usr/local/bin/"; \
	fi

# Generate documentation
docs:
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table . > README.md.tmp; \
		echo "Documentation generated. Review README.md.tmp"; \
	else \
		echo "terraform-docs not found. Install with: go install github.com/terraform-docs/terraform-docs/cmd/terraform-docs@latest"; \
	fi

# Setup development environment
setup-dev:
	@echo "Setting up development environment..."
	@if command -v go >/dev/null 2>&1; then \
		go install github.com/terraform-linters/tflint/cmd/tflint@latest; \
		go install github.com/terraform-docs/terraform-docs/cmd/terraform-docs@latest; \
		go install github.com/gruntwork-io/terratest/modules/terratest@latest; \
	else \
		echo "Go not found. Please install Go first."; \
	fi

# Check all (validate, fmt, lint)
check: validate fmt lint
	@echo "All checks completed successfully!"

# Full deployment workflow
deploy: init validate fmt lint plan apply
	@echo "Deployment completed successfully!"

# Full cleanup workflow
cleanup: destroy clean
	@echo "Cleanup completed successfully!" 