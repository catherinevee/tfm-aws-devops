# Test configuration for AWS DevOps Pipeline Module

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "devops_pipeline_test" {
  source = "../"

  project_name = "test-webapp"
  environment  = "dev"
  
  # Minimal configuration for testing
  build_timeout = 30
  log_retention_days = 7
  enable_cloudtrail = false
  
  tags = {
    Environment = "test"
    Project     = "test-webapp"
    Owner       = "test-team"
    Purpose     = "testing"
  }
}

# Outputs for testing
output "repository_name" {
  value = module.devops_pipeline_test.codecommit_repository_name
}

output "build_project_name" {
  value = module.devops_pipeline_test.codebuild_project_name
}

output "deployment_app_name" {
  value = module.devops_pipeline_test.codedeploy_app_name
}

output "artifacts_bucket_name" {
  value = module.devops_pipeline_test.artifacts_bucket_name
} 