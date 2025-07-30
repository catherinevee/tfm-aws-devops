# Advanced Example - AWS DevOps Pipeline
# This example shows how to use the module with all features enabled

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

# SNS Topic for alarms
resource "aws_sns_topic" "alerts" {
  name = "my-webapp-alerts"
  
  tags = {
    Environment = "production"
    Project     = "my-webapp"
  }
}

# CloudWatch Alarms for deployment monitoring
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "my-webapp-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = "production"
    Project     = "my-webapp"
  }
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "my-webapp-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors memory utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = "production"
    Project     = "my-webapp"
  }
}

module "devops_pipeline" {
  source = "../../"

  project_name = "my-webapp"
  environment  = "prod"
  
  # Build configuration
  build_timeout      = 120
  build_compute_type = "BUILD_GENERAL1_MEDIUM"
  build_image        = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  buildspec_path     = "buildspec.yml"
  
  # Deployment configuration
  deployment_alarms = [
    aws_cloudwatch_metric_alarm.high_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.high_memory.alarm_name
  ]
  alarm_actions = [aws_sns_topic.alerts.arn]
  
  # CloudFormation stack
  create_cloudformation_stack = true
  cloudformation_template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09"
    Description              = "Infrastructure for my-webapp"
    
    Parameters = {
      Environment = {
        Type        = "String"
        Default     = "prod"
        Description = "Environment name"
      }
    }
    
    Resources = {
      # Example: Create an S3 bucket for application data
      ApplicationBucket = {
        Type = "AWS::S3::Bucket"
        Properties = {
          BucketName = "my-webapp-data-prod"
          VersioningConfiguration = {
            Status = "Enabled"
          }
          PublicAccessBlockConfiguration = {
            BlockPublicAcls       = true
            BlockPublicPolicy     = true
            IgnorePublicAcls      = true
            RestrictPublicBuckets = true
          }
          Tags = [
            {
              Key   = "Environment"
              Value = { "Ref": "Environment" }
            },
            {
              Key   = "Project"
              Value = "my-webapp"
            }
          ]
        }
      }
      
      # Example: Create a DynamoDB table
      ApplicationTable = {
        Type = "AWS::DynamoDB::Table"
        Properties = {
          TableName = "my-webapp-table"
          BillingMode = "PAY_PER_REQUEST"
          AttributeDefinitions = [
            {
              AttributeName = "id"
              AttributeType = "S"
            }
          ]
          KeySchema = [
            {
              AttributeName = "id"
              KeyType       = "HASH"
            }
          ]
          Tags = [
            {
              Key   = "Environment"
              Value = { "Ref": "Environment" }
            },
            {
              Key   = "Project"
              Value = "my-webapp"
            }
          ]
        }
      }
    }
    
    Outputs = {
      ApplicationBucketName = {
        Description = "Name of the application data bucket"
        Value       = { "Ref": "ApplicationBucket" }
      }
      ApplicationTableName = {
        Description = "Name of the application DynamoDB table"
        Value       = { "Ref": "ApplicationTable" }
      }
    }
  })
  
  cloudformation_parameters = {
    Environment = "prod"
  }
  
  # SSM Parameters
  ssm_parameters = {
    database_url = {
      description = "Database connection URL"
      type        = "SecureString"
      value       = "postgresql://user:password@my-db-cluster.cluster-xyz.us-east-1.rds.amazonaws.com:5432/mywebapp"
      tier        = "Standard"
    }
    api_key = {
      description = "API key for external service"
      type        = "SecureString"
      value       = "sk-1234567890abcdef1234567890abcdef"
      tier        = "Standard"
    }
    redis_url = {
      description = "Redis connection URL"
      type        = "SecureString"
      value       = "redis://my-redis-cluster.xyz.cache.amazonaws.com:6379"
      tier        = "Standard"
    }
    app_secret = {
      description = "Application secret key"
      type        = "SecureString"
      value       = "my-super-secret-key-for-jwt-tokens"
      tier        = "Standard"
    }
    environment = {
      description = "Application environment"
      type        = "String"
      value       = "production"
      tier        = "Standard"
    }
  }
  
  # Monitoring configuration
  log_retention_days = 90
  enable_cloudtrail  = true
  
  tags = {
    Environment = "production"
    Project     = "my-webapp"
    Owner       = "devops-team"
    CostCenter  = "engineering"
    Compliance  = "SOC2"
    Backup      = "daily"
  }
} 