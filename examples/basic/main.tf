# Basic Example - AWS DevOps Pipeline
# This example shows how to use the module with minimal configuration

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

module "devops_pipeline" {
  source = "../../"

  project_name = "my-webapp"
  environment  = "dev"
  
  tags = {
    Environment = "development"
    Project     = "my-webapp"
    Owner       = "devops-team"
    CostCenter  = "engineering"
  }
}

# Output the important information
output "repository_url" {
  description = "CodeCommit repository URL"
  value       = module.devops_pipeline.codecommit_clone_url_http
}

output "build_project" {
  description = "CodeBuild project name"
  value       = module.devops_pipeline.codebuild_project_name
}

output "deployment_app" {
  description = "CodeDeploy application name"
  value       = module.devops_pipeline.codedeploy_app_name
}

output "artifacts_bucket" {
  description = "S3 bucket for artifacts"
  value       = module.devops_pipeline.artifacts_bucket_name
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=${module.devops_pipeline.cloudwatch_dashboard_name}"
} 