# Variables for AWS DevOps Pipeline Module

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.project_name))
    error_message = "Project name must contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "build_timeout" {
  description = "Build timeout in minutes"
  type        = number
  default     = 60
  validation {
    condition     = var.build_timeout >= 5 && var.build_timeout <= 480
    error_message = "Build timeout must be between 5 and 480 minutes."
  }
}

variable "build_compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
  validation {
    condition     = contains(["BUILD_GENERAL1_SMALL", "BUILD_GENERAL1_MEDIUM", "BUILD_GENERAL1_LARGE", "BUILD_GENERAL1_2XLARGE"], var.build_compute_type)
    error_message = "Build compute type must be one of the valid BUILD_GENERAL1 types."
  }
}

variable "build_image" {
  description = "CodeBuild build image"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
}

variable "buildspec_path" {
  description = "Path to the buildspec file in the repository"
  type        = string
  default     = "buildspec.yml"
}

variable "deployment_alarms" {
  description = "List of CloudWatch alarm names for deployment rollback"
  type        = list(string)
  default     = []
}

variable "alarm_actions" {
  description = "List of ARNs for alarm actions (e.g., SNS topics)"
  type        = list(string)
  default     = []
}

variable "create_cloudformation_stack" {
  description = "Whether to create a CloudFormation stack"
  type        = bool
  default     = false
}

variable "cloudformation_template_body" {
  description = "CloudFormation template body"
  type        = string
  default     = ""
  validation {
    condition     = var.cloudformation_template_body == "" || can(jsondecode(var.cloudformation_template_body))
    error_message = "CloudFormation template body must be valid JSON when provided."
  }
}

variable "cloudformation_parameters" {
  description = "Parameters for CloudFormation stack"
  type        = map(string)
  default     = {}
}

variable "ssm_parameters" {
  description = "Map of SSM Parameter Store parameters"
  type = map(object({
    description = string
    type        = string
    value       = string
    tier        = string
  }))
  default = {}
  validation {
    condition = alltrue([
      for param in values(var.ssm_parameters) : contains(["String", "StringList", "SecureString"], param.type)
    ])
    error_message = "SSM parameter type must be one of: String, StringList, SecureString."
  }
  validation {
    condition = alltrue([
      for param in values(var.ssm_parameters) : contains(["Standard", "Advanced", "Intelligent-Tiering"], param.tier)
    ])
    error_message = "SSM parameter tier must be one of: Standard, Advanced, Intelligent-Tiering."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be one of the valid CloudWatch retention periods."
  }
}

variable "enable_cloudtrail" {
  description = "Whether to enable CloudTrail logging"
  type        = bool
  default     = true
} 