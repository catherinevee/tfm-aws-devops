# Outputs for Advanced Example

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

output "cloudformation_stack_name" {
  description = "CloudFormation stack name"
  value       = module.devops_pipeline.cloudformation_stack_name
}

output "cloudformation_stack_id" {
  description = "CloudFormation stack ID"
  value       = module.devops_pipeline.cloudformation_stack_id
}

output "ssm_parameters" {
  description = "SSM Parameter Store parameters"
  value       = module.devops_pipeline.ssm_parameters
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "alarm_names" {
  description = "Names of CloudWatch alarms"
  value = {
    high_cpu    = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
    high_memory = aws_cloudwatch_metric_alarm.high_memory.alarm_name
  }
}

output "iam_roles" {
  description = "IAM roles created by the module"
  value       = module.devops_pipeline.iam_roles
}

output "log_groups" {
  description = "CloudWatch log groups"
  value       = module.devops_pipeline.log_groups
} 