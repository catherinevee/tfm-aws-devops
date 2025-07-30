# Basic Example - AWS DevOps Pipeline

This example demonstrates how to use the AWS DevOps Pipeline module with minimal configuration.

## What this example creates

- **CodeCommit Repository**: Git repository for source code
- **CodeBuild Project**: Automated build and test pipeline
- **CodeDeploy Application**: Automated deployment with rollback
- **S3 Bucket**: Encrypted bucket for build artifacts
- **CloudWatch Dashboard**: Monitoring dashboard for build and deployment metrics
- **X-Ray Group**: Distributed tracing group
- **CloudTrail**: API call logging for audit compliance
- **IAM Roles**: Service roles with appropriate permissions

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

## Next Steps

After deploying this example:

1. **Clone the repository**:
   ```bash
   git clone $(terraform output -raw repository_url)
   ```

2. **Add your application code** to the repository

3. **Create a buildspec.yml** file in your repository root (see the main README for an example)

4. **Push your code** to trigger the first build:
   ```bash
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

5. **Monitor the build** in the AWS CodeBuild console

6. **View the dashboard** using the CloudWatch dashboard URL from the outputs

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Configuration

This example uses the following configuration:

- **Project Name**: `my-webapp`
- **Environment**: `dev`
- **Region**: `us-east-1`
- **Build Timeout**: 60 minutes (default)
- **Build Compute Type**: `BUILD_GENERAL1_SMALL` (default)
- **Log Retention**: 30 days (default)

## Customization

You can customize this example by modifying the variables in `main.tf`:

- Change the `project_name` to match your application
- Update the `environment` (dev, staging, prod)
- Modify the `tags` for your organization's tagging strategy
- Adjust the AWS region in the provider configuration 