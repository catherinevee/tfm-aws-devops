# Test outputs for AWS DevOps Pipeline Module

output "repository_name" {
  description = "CodeCommit repository name for testing"
  value       = module.devops_pipeline_test.codecommit_repository_name
}

output "build_project_name" {
  description = "CodeBuild project name for testing"
  value       = module.devops_pipeline_test.codebuild_project_name
}

output "deployment_app_name" {
  description = "CodeDeploy application name for testing"
  value       = module.devops_pipeline_test.codedeploy_app_name
}

output "artifacts_bucket_name" {
  description = "S3 artifacts bucket name for testing"
  value       = module.devops_pipeline_test.artifacts_bucket_name
}

output "dashboard_name" {
  description = "CloudWatch dashboard name for testing"
  value       = module.devops_pipeline_test.cloudwatch_dashboard_name
}

output "xray_group_name" {
  description = "X-Ray group name for testing"
  value       = module.devops_pipeline_test.xray_group_name
} 