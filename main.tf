# AWS DevOps Pipeline Module
# This module creates a comprehensive DevOps pipeline with:
# - Build Pipeline: CodeCommit + CodeBuild + CodeDeploy
# - Infrastructure: CloudFormation + Systems Manager
# - Monitoring: CloudWatch + X-Ray + CloudTrail

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# IAM Roles and Policies
# =====================

# CodeBuild Service Role
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# CodeBuild Policy
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.project_name}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Resource = ["*"]
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        Effect = "Allow"
        Resource = ["*"]
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
      },
      {
        Effect = "Allow"
        Resource = ["*"]
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
      },
      {
        Effect = "Allow"
        Resource = ["*"]
        Action = [
          "cloudformation:*",
          "ssm:*",
          "xray:*"
        ]
      }
    ]
  })
}

# CodeDeploy Service Role
resource "aws_iam_role" "codedeploy_role" {
  name = "${var.project_name}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach AWS managed policy for CodeDeploy
resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# CloudWatch Role for X-Ray
resource "aws_iam_role" "xray_role" {
  name = "${var.project_name}-xray-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# X-Ray Policy
resource "aws_iam_role_policy" "xray_policy" {
  name = "${var.project_name}-xray-policy"
  role = aws_iam_role.xray_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# S3 Bucket for Artifacts
# ======================

resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-artifacts-${random_string.bucket_suffix.result}"

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Random string for bucket naming
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# CodeCommit Repository
# ====================

resource "aws_codecommit_repository" "main" {
  repository_name = "${var.project_name}-repository"
  description     = "Main application repository for ${var.project_name}"

  tags = var.tags
}

# CodeBuild Project
# ================

resource "aws_codebuild_project" "main" {
  name          = "${var.project_name}-build"
  description   = "Build project for ${var.project_name}"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "S3"
    location = aws_s3_bucket.artifacts.bucket
    name     = "build-artifacts"
  }

  environment {
    compute_type                = var.build_compute_type
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }
  }

  source {
    type      = "CODECOMMIT"
    location  = aws_codecommit_repository.main.clone_url_http
    buildspec = var.buildspec_path
  }

  cache {
    type  = "S3"
    location = "${aws_s3_bucket.artifacts.bucket}/cache"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.project_name}"
      stream_name = "build-log"
    }
  }

  tags = var.tags
}

# CodeDeploy Application and Deployment Group
# ===========================================

resource "aws_codedeploy_app" "main" {
  name             = "${var.project_name}-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "main" {
  app_name               = aws_codedeploy_app.main.name
  deployment_group_name  = "${var.project_name}-deployment-group"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = var.environment
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  alarm_configuration {
    enabled = true
    alarms  = var.deployment_alarms
  }

  tags = var.tags
}

# CloudFormation Stack
# ====================

resource "aws_cloudformation_stack" "infrastructure" {
  count = var.create_cloudformation_stack ? 1 : 0

  name          = "${var.project_name}-infrastructure"
  template_body = var.cloudformation_template_body
  capabilities  = ["CAPABILITY_NAMED_IAM"]

  parameters = var.cloudformation_parameters

  tags = var.tags
}

# Systems Manager Parameter Store
# ==============================

resource "aws_ssm_parameter" "app_config" {
  for_each = var.ssm_parameters

  name        = "/${var.project_name}/${each.key}"
  description = each.value.description
  type        = each.value.type
  value       = each.value.value
  tier        = each.value.tier

  tags = merge(var.tags, {
    ParameterName = each.key
  })
}

# CloudWatch Log Groups
# ====================

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/application/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "build" {
  name              = "/aws/codebuild/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# CloudWatch Alarms
# =================

resource "aws_cloudwatch_metric_alarm" "deployment_failure" {
  count = length(var.deployment_alarms) > 0 ? 1 : 0

  alarm_name          = "${var.project_name}-deployment-failure"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DeploymentFailures"
  namespace           = "AWS/CodeDeploy"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors deployment failures"
  alarm_actions       = var.alarm_actions

  tags = var.tags
}

# X-Ray Group
# ===========

resource "aws_xray_group" "main" {
  group_name        = "${var.project_name}-group"
  filter_expression = "service(\"${var.project_name}\")"

  tags = var.tags
}

# CloudTrail
# ==========

resource "aws_cloudtrail" "main" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = "${var.project_name}-trail"
  s3_bucket_name               = aws_s3_bucket.artifacts.bucket
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true

  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.artifacts.arn}/*"]
    }
  }

  tags = var.tags
}

# CloudWatch Dashboard
# ===================

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/CodeBuild", "BuildDuration", "ProjectName", aws_codebuild_project.main.name],
            [".", "Builds", ".", "."],
            [".", "FailedBuilds", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "CodeBuild Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/CodeDeploy", "DeploymentDuration", "ApplicationName", aws_codedeploy_app.main.name],
            [".", "DeploymentFailures", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "CodeDeploy Metrics"
        }
      }
    ]
  })
} 