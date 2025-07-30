# Outputs for Basic Example

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

output "xray_group" {
  description = "X-Ray group name"
  value       = module.devops_pipeline.xray_group_name
}

output "cloudtrail_name" {
  description = "CloudTrail name"
  value       = module.devops_pipeline.cloudtrail_name
} 