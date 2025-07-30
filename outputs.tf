# Outputs for AWS DevOps Pipeline Module

output "codecommit_repository_name" {
  description = "Name of the CodeCommit repository"
  value       = aws_codecommit_repository.main.repository_name
}

output "codecommit_repository_id" {
  description = "ID of the CodeCommit repository"
  value       = aws_codecommit_repository.main.repository_id
}

output "codecommit_clone_url_http" {
  description = "HTTP clone URL for the CodeCommit repository"
  value       = aws_codecommit_repository.main.clone_url_http
}

output "codecommit_clone_url_ssh" {
  description = "SSH clone URL for the CodeCommit repository"
  value       = aws_codecommit_repository.main.clone_url_ssh
}

output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = aws_codebuild_project.main.name
}

output "codebuild_project_arn" {
  description = "ARN of the CodeBuild project"
  value       = aws_codebuild_project.main.arn
}

output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = aws_codedeploy_app.main.name
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.main.deployment_group_name
}

output "artifacts_bucket_name" {
  description = "Name of the S3 bucket for artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifacts_bucket_arn" {
  description = "ARN of the S3 bucket for artifacts"
  value       = aws_s3_bucket.artifacts.arn
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "cloudwatch_dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "xray_group_name" {
  description = "Name of the X-Ray group"
  value       = aws_xray_group.main.group_name
}

output "xray_group_arn" {
  description = "ARN of the X-Ray group"
  value       = aws_xray_group.main.arn
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].name : null
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].arn : null
}

output "cloudformation_stack_name" {
  description = "Name of the CloudFormation stack"
  value       = var.create_cloudformation_stack ? aws_cloudformation_stack.infrastructure[0].name : null
}

output "cloudformation_stack_id" {
  description = "ID of the CloudFormation stack"
  value       = var.create_cloudformation_stack ? aws_cloudformation_stack.infrastructure[0].id : null
}

output "iam_roles" {
  description = "Map of IAM roles created by the module"
  value = {
    codebuild = aws_iam_role.codebuild_role.arn
    codedeploy = aws_iam_role.codedeploy_role.arn
    xray = aws_iam_role.xray_role.arn
  }
}

output "log_groups" {
  description = "Map of CloudWatch log groups created by the module"
  value = {
    application = aws_cloudwatch_log_group.application.name
    build = aws_cloudwatch_log_group.build.name
  }
}

output "ssm_parameters" {
  description = "Map of SSM Parameter Store parameters created by the module"
  value = {
    for key, param in aws_ssm_parameter.app_config : key => {
      name = param.name
      arn = param.arn
      type = param.type
    }
  }
} 