# AWS DevOps Pipeline Terraform Module

A comprehensive Terraform module for creating a complete AWS DevOps pipeline with build automation, infrastructure management, and monitoring capabilities.

## Features

### 🚀 Build Pipeline
- **AWS CodeCommit**: Secure Git repository for source code management
- **AWS CodeBuild**: Automated build and test processes
- **AWS CodeDeploy**: Automated deployment with rollback capabilities

### 🏗️ Infrastructure Management
- **AWS CloudFormation**: Infrastructure as Code with template management
- **AWS Systems Manager**: Parameter Store for configuration management

### 📊 Monitoring & Observability
- **AWS CloudWatch**: Logs, metrics, and dashboards
- **AWS X-Ray**: Distributed tracing for applications
- **AWS CloudTrail**: API call logging and audit trail

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CodeCommit    │───▶│   CodeBuild     │───▶│  CodeDeploy     │
│   Repository    │    │   Project       │    │  Application    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   S3 Artifacts  │    │  CloudWatch     │    │  CloudFormation │
│     Bucket      │    │    Logs         │    │     Stack       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CloudTrail    │    │   X-Ray Group   │    │  SSM Parameter  │
│     Logging     │    │                 │    │     Store       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Usage

### Basic Example

```hcl
module "devops_pipeline" {
  source = "./tfm-aws-devops"

  project_name = "my-application"
  environment  = "prod"
  
  tags = {
    Environment = "production"
    Project     = "my-application"
    Owner       = "devops-team"
  }
}
```

### Advanced Example

```hcl
module "devops_pipeline" {
  source = "./tfm-aws-devops"

  project_name = "my-application"
  environment  = "prod"
  
  # Build configuration
  build_timeout     = 120
  build_compute_type = "BUILD_GENERAL1_MEDIUM"
  build_image       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  buildspec_path    = "buildspec.yml"
  
  # Deployment configuration
  deployment_alarms = ["my-application-high-cpu", "my-application-high-memory"]
  alarm_actions     = ["arn:aws:sns:us-east-1:123456789012:alerts-topic"]
  
  # CloudFormation stack
  create_cloudformation_stack = true
  cloudformation_template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09"
    Resources = {
      # Your CloudFormation resources here
    }
  })
  
  # SSM Parameters
  ssm_parameters = {
    database_url = {
      description = "Database connection URL"
      type        = "SecureString"
      value       = "postgresql://user:pass@host:5432/db"
      tier        = "Standard"
    }
    api_key = {
      description = "API key for external service"
      type        = "SecureString"
      value       = "your-api-key-here"
      tier        = "Standard"
    }
  }
  
  # Monitoring configuration
  log_retention_days = 90
  enable_cloudtrail  = true
  
  tags = {
    Environment = "production"
    Project     = "my-application"
    Owner       = "devops-team"
    CostCenter  = "engineering"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |
| random | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |
| random | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project, used for resource naming | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |
| build_timeout | Build timeout in minutes | `number` | `60` | no |
| build_compute_type | CodeBuild compute type | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| build_image | CodeBuild build image | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:4.0"` | no |
| buildspec_path | Path to the buildspec file in the repository | `string` | `"buildspec.yml"` | no |
| deployment_alarms | List of CloudWatch alarm names for deployment rollback | `list(string)` | `[]` | no |
| alarm_actions | List of ARNs for alarm actions (e.g., SNS topics) | `list(string)` | `[]` | no |
| create_cloudformation_stack | Whether to create a CloudFormation stack | `bool` | `false` | no |
| cloudformation_template_body | CloudFormation template body | `string` | `""` | no |
| cloudformation_parameters | Parameters for CloudFormation stack | `map(string)` | `{}` | no |
| ssm_parameters | Map of SSM Parameter Store parameters | `map(object)` | `{}` | no |
| log_retention_days | Number of days to retain CloudWatch logs | `number` | `30` | no |
| enable_cloudtrail | Whether to enable CloudTrail logging | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| codecommit_repository_name | Name of the CodeCommit repository |
| codecommit_repository_id | ID of the CodeCommit repository |
| codecommit_clone_url_http | HTTP clone URL for the CodeCommit repository |
| codecommit_clone_url_ssh | SSH clone URL for the CodeCommit repository |
| codebuild_project_name | Name of the CodeBuild project |
| codebuild_project_arn | ARN of the CodeBuild project |
| codedeploy_app_name | Name of the CodeDeploy application |
| codedeploy_deployment_group_name | Name of the CodeDeploy deployment group |
| artifacts_bucket_name | Name of the S3 bucket for artifacts |
| artifacts_bucket_arn | ARN of the S3 bucket for artifacts |
| cloudwatch_dashboard_name | Name of the CloudWatch dashboard |
| cloudwatch_dashboard_arn | ARN of the CloudWatch dashboard |
| xray_group_name | Name of the X-Ray group |
| xray_group_arn | ARN of the X-Ray group |
| cloudtrail_name | Name of the CloudTrail |
| cloudtrail_arn | ARN of the CloudTrail |
| cloudformation_stack_name | Name of the CloudFormation stack |
| cloudformation_stack_id | ID of the CloudFormation stack |
| iam_roles | Map of IAM roles created by the module |
| log_groups | Map of CloudWatch log groups created by the module |
| ssm_parameters | Map of SSM Parameter Store parameters created by the module |

## Examples

### Basic Example
See the `examples/basic` directory for a minimal setup.

### Advanced Example
See the `examples/advanced` directory for a comprehensive setup with all features enabled.

## Buildspec Example

Create a `buildspec.yml` file in your repository root:

```yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - aws sts get-caller-identity
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t $PROJECT_NAME .
      - docker tag $PROJECT_NAME:$IMAGE_TAG $REPOSITORY_URI:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - printf '[{"name":"app","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json

artifacts:
  files:
    - imagedefinitions.json
    - appspec.yml
    - taskdef.json
  discard-paths: yes
```

## Security Considerations

- All S3 buckets are encrypted and have public access blocked
- IAM roles follow the principle of least privilege
- CloudTrail is enabled for audit logging
- SSM parameters support SecureString type for sensitive data
- All resources are tagged for cost tracking and security

## Best Practices

1. **Use workspaces** for environment separation (dev, staging, prod)
2. **Enable CloudTrail** for audit compliance
3. **Use SecureString** for sensitive SSM parameters
4. **Set up CloudWatch alarms** for deployment monitoring
5. **Tag all resources** for cost tracking and security
6. **Use version constraints** for providers and modules
7. **Enable S3 bucket versioning** for artifact backup
8. **Configure log retention** based on compliance requirements

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See the LICENSE file for details.

## Support

For issues and questions:
1. Check the [examples](./examples) directory
2. Review the [Terraform documentation](https://www.terraform.io/docs)
3. Open an issue in the repository