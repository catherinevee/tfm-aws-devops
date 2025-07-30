# Advanced Example - AWS DevOps Pipeline

This example demonstrates how to use the AWS DevOps Pipeline module with all features enabled, including CloudFormation stacks, SSM parameters, advanced monitoring, and deployment alarms.

## What this example creates

### Core DevOps Pipeline
- **CodeCommit Repository**: Git repository for source code management
- **CodeBuild Project**: Automated build and test pipeline with medium compute resources
- **CodeDeploy Application**: Automated deployment with rollback capabilities
- **S3 Bucket**: Encrypted bucket for build artifacts with versioning

### Infrastructure Management
- **CloudFormation Stack**: Creates application infrastructure (S3 bucket and DynamoDB table)
- **SSM Parameter Store**: Stores application configuration securely
- **IAM Roles**: Service roles with appropriate permissions

### Monitoring & Observability
- **CloudWatch Dashboard**: Comprehensive monitoring dashboard
- **CloudWatch Alarms**: CPU and memory utilization alarms with SNS notifications
- **X-Ray Group**: Distributed tracing for application performance
- **CloudTrail**: API call logging for audit compliance
- **SNS Topic**: Alert notifications for monitoring events

## Features Demonstrated

### 1. Advanced Build Configuration
- 120-minute build timeout
- Medium compute resources for faster builds
- Custom build image
- S3 caching for build optimization

### 2. Deployment Monitoring
- CloudWatch alarms for CPU and memory utilization
- Automatic rollback on alarm triggers
- SNS notifications for deployment events

### 3. Infrastructure as Code
- CloudFormation stack with S3 bucket and DynamoDB table
- Parameterized templates
- Secure resource configuration

### 4. Configuration Management
- SSM Parameter Store with SecureString parameters
- Database connection strings
- API keys and secrets
- Environment-specific configuration

### 5. Comprehensive Monitoring
- 90-day log retention
- Multi-region CloudTrail
- Custom CloudWatch dashboard
- X-Ray distributed tracing

## Usage

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Review the plan**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

4. **View outputs**:
   ```bash
   terraform output
   ```

## Configuration Details

### Build Configuration
- **Project Name**: `my-webapp`
- **Environment**: `prod`
- **Build Timeout**: 120 minutes
- **Compute Type**: `BUILD_GENERAL1_MEDIUM`
- **Build Image**: `aws/codebuild/amazonlinux2-x86_64-standard:4.0`

### Monitoring Configuration
- **Log Retention**: 90 days
- **CloudTrail**: Enabled with multi-region logging
- **Alarms**: CPU > 80% and Memory > 85%
- **SNS Notifications**: Enabled for all alarms

### SSM Parameters
- `database_url`: PostgreSQL connection string (SecureString)
- `api_key`: External service API key (SecureString)
- `redis_url`: Redis connection string (SecureString)
- `app_secret`: JWT secret key (SecureString)
- `environment`: Application environment (String)

### CloudFormation Resources
- **S3 Bucket**: Application data storage with versioning
- **DynamoDB Table**: NoSQL database with on-demand billing

## Security Features

- All S3 buckets are encrypted and have public access blocked
- SSM parameters use SecureString type for sensitive data
- IAM roles follow the principle of least privilege
- CloudTrail provides comprehensive audit logging
- All resources are tagged for security and compliance

## Next Steps

After deploying this example:

1. **Clone the repository**:
   ```bash
   git clone $(terraform output -raw repository_url)
   ```

2. **Add your application code** to the repository

3. **Create a buildspec.yml** file in your repository root

4. **Configure your application** to use the SSM parameters:
   ```bash
   # Get database URL
   aws ssm get-parameter --name "/my-webapp/database_url" --with-decryption
   
   # Get API key
   aws ssm get-parameter --name "/my-webapp/api_key" --with-decryption
   ```

5. **Push your code** to trigger the first build:
   ```bash
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

6. **Monitor the deployment** using the CloudWatch dashboard

7. **Set up SNS subscriptions** for alert notifications

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Note**: This will delete all resources including the CloudFormation stack, SSM parameters, and application data. Make sure to backup any important data before running destroy.

## Customization

You can customize this example by:

- **Modifying the CloudFormation template** to include your specific infrastructure needs
- **Adding more SSM parameters** for additional configuration
- **Creating additional CloudWatch alarms** for specific metrics
- **Configuring SNS subscriptions** for different notification channels
- **Adjusting resource sizes** based on your application requirements

## Cost Considerations

This example creates several AWS resources that will incur costs:

- **CodeBuild**: Pay per build minute
- **CloudTrail**: Storage costs for log files
- **CloudWatch**: Log storage and metric retention
- **S3**: Storage and data transfer costs
- **DynamoDB**: On-demand billing for table access
- **X-Ray**: Trace data storage costs

Monitor your AWS billing dashboard to track costs and adjust resources as needed. 