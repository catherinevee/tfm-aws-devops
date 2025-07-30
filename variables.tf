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

# ==============================================================================
# Enhanced DevOps Pipeline Configuration Variables
# ==============================================================================

variable "devops_config" {
  description = "DevOps pipeline configuration"
  type = object({
    enable_continuous_integration = optional(bool, true)
    enable_continuous_deployment = optional(bool, true)
    enable_continuous_monitoring = optional(bool, true)
    enable_automated_testing = optional(bool, true)
    enable_security_scanning = optional(bool, true)
    enable_compliance_checking = optional(bool, false)
    enable_artifact_management = optional(bool, true)
    enable_environment_management = optional(bool, true)
    enable_rollback_strategy = optional(bool, true)
    enable_blue_green_deployment = optional(bool, false)
    enable_canary_deployment = optional(bool, false)
    enable_feature_flags = optional(bool, false)
    enable_chaos_engineering = optional(bool, false)
    enable_infrastructure_as_code = optional(bool, true)
    enable_configuration_management = optional(bool, true)
    enable_secrets_management = optional(bool, true)
    enable_log_aggregation = optional(bool, true)
    enable_metrics_collection = optional(bool, true)
    enable_alerting = optional(bool, true)
    enable_dashboard = optional(bool, true)
    enable_audit_logging = optional(bool, true)
    enable_backup_strategy = optional(bool, true)
    enable_disaster_recovery = optional(bool, false)
  })
  default = {}
}

# ==============================================================================
# Enhanced CodePipeline Configuration Variables
# ==============================================================================

variable "codepipeline_config" {
  description = "CodePipeline configuration"
  type = object({
    name = optional(string, null)
    role_arn = optional(string, null)
    artifact_store = optional(object({
      location = optional(string, null)
      type = optional(string, "S3")
      encryption_key = optional(object({
        id = string
        type = string
      }), {})
    }), {})
    stages = list(object({
      name = string
      actions = list(object({
        name = string
        category = string
        owner = string
        provider = string
        version = optional(string, "1")
        region = optional(string, null)
        role_arn = optional(string, null)
        run_order = optional(number, 1)
        configuration = optional(map(string), {})
        input_artifacts = optional(list(string), [])
        output_artifacts = optional(list(string), [])
        namespace = optional(string, null)
        region = optional(string, null)
        role_arn = optional(string, null)
        run_order = optional(number, 1)
        configuration = optional(map(string), {})
        input_artifacts = optional(list(string), [])
        output_artifacts = optional(list(string), [])
        namespace = optional(string, null)
      }))
    }))
    tags = optional(map(string), {})
  })
  default = {}
}

variable "codepipeline_webhooks" {
  description = "Map of CodePipeline webhooks to create"
  type = map(object({
    name = string
    authentication_configuration = object({
      allowed_ip_range = optional(string, null)
      secret_token = optional(string, null)
    })
    filter = list(object({
      json_path = string
      match_equals = string
    }))
    target_action = string
    target_pipeline = string
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced CodeBuild Configuration Variables
# ==============================================================================

variable "codebuild_projects" {
  description = "Map of CodeBuild projects to create"
  type = map(object({
    name = string
    description = optional(string, null)
    build_timeout = optional(number, 60)
    queued_timeout = optional(number, 480)
    service_role = string
    artifacts = object({
      type = string
      location = optional(string, null)
      path = optional(string, null)
      namespace_type = optional(string, null)
      name = optional(string, null)
      packaging = optional(string, null)
      override_artifact_name = optional(bool, null)
      encryption_disabled = optional(bool, null)
      artifact_identifier = optional(string, null)
      bucket_owner_access = optional(string, null)
    })
    cache = optional(object({
      type = optional(string, null)
      location = optional(string, null)
      modes = optional(list(string), [])
    }), {})
    environment = object({
      compute_type = string
      image = string
      type = string
      image_pull_credentials_type = optional(string, null)
      certificate = optional(string, null)
      privileged_mode = optional(bool, null)
      environment_variable = optional(list(object({
        name = string
        value = optional(string, null)
        type = optional(string, null)
      })), [])
      registry_credential = optional(object({
        credential = string
        credential_provider = string
      }), {})
    })
    source = object({
      type = string
      location = optional(string, null)
      git_clone_depth = optional(number, null)
      git_submodules_config = optional(object({
        fetch_submodules = bool
      }), {})
      buildspec = optional(string, null)
      auth = optional(object({
        type = string
        resource = optional(string, null)
      }), {})
      report_build_status = optional(bool, null)
      insecure_ssl = optional(bool, null)
    })
    vpc_config = optional(object({
      vpc_id = string
      subnets = list(string)
      security_group_ids = list(string)
    }), {})
    logs_config = optional(object({
      cloudwatch_logs = optional(object({
        group_name = optional(string, null)
        stream_name = optional(string, null)
        status = optional(string, "ENABLED")
      }), {})
      s3_logs = optional(object({
        status = optional(string, "DISABLED")
        location = optional(string, null)
        encryption_disabled = optional(bool, null)
      }), {})
    }), {})
    secondary_artifacts = optional(list(object({
      artifact_identifier = string
      type = string
      location = optional(string, null)
      path = optional(string, null)
      namespace_type = optional(string, null)
      name = optional(string, null)
      packaging = optional(string, null)
      override_artifact_name = optional(bool, null)
      encryption_disabled = optional(bool, null)
      bucket_owner_access = optional(string, null)
    })), [])
    secondary_sources = optional(list(object({
      source_identifier = string
      type = string
      location = optional(string, null)
      git_clone_depth = optional(number, null)
      git_submodules_config = optional(object({
        fetch_submodules = bool
      }), {})
      buildspec = optional(string, null)
      auth = optional(object({
        type = string
        resource = optional(string, null)
      }), {})
      report_build_status = optional(bool, null)
      insecure_ssl = optional(bool, null)
    })), [])
    source_version = optional(string, null)
    badge_enabled = optional(bool, null)
    encryption_disabled = optional(bool, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "codebuild_source_credentials" {
  description = "Map of CodeBuild source credentials to create"
  type = map(object({
    auth_type = string
    server_type = string
    token = string
    user_name = optional(string, null)
  }))
  default = {}
}

variable "codebuild_report_groups" {
  description = "Map of CodeBuild report groups to create"
  type = map(object({
    name = string
    type = string
    export_config = object({
      type = string
      s3_destination = optional(object({
        bucket = string
        encryption_key = optional(string, null)
        packaging = optional(string, null)
        path = optional(string, null)
      }), {})
    })
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced CodeDeploy Configuration Variables
# ==============================================================================

variable "codedeploy_applications" {
  description = "Map of CodeDeploy applications to create"
  type = map(object({
    name = string
    compute_platform = optional(string, "Server")
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "codedeploy_deployment_groups" {
  description = "Map of CodeDeploy deployment groups to create"
  type = map(object({
    app_name = string
    deployment_group_name = string
    service_role_arn = string
    deployment_style = optional(object({
      deployment_option = optional(string, "WITH_TRAFFIC_CONTROL")
      deployment_type = optional(string, "IN_PLACE")
    }), {})
    ec2_tag_set = optional(list(object({
      ec2_tag_filter = list(object({
        key = optional(string, null)
        type = optional(string, null)
        value = optional(string, null)
      }))
    })), [])
    ecs_service = optional(object({
      cluster_name = string
      service_name = string
    }), {})
    load_balancer_info = optional(object({
      elb_info = optional(list(object({
        name = optional(string, null)
      })), [])
      target_group_info = optional(list(object({
        name = optional(string, null)
      })), [])
      target_group_pair_info = optional(object({
        prod_traffic_route = object({
          listener_arns = list(string)
        })
        target_groups = list(object({
          name = string
        }))
        test_traffic_route = optional(object({
          listener_arns = list(string)
        }), {})
      }), {})
    }), {})
    on_premises_instance_tag_set = optional(list(object({
      on_premises_tag_filter = list(object({
        key = optional(string, null)
        type = optional(string, null)
        value = optional(string, null)
      }))
    })), [])
    trigger_configuration = optional(list(object({
      trigger_events = list(string)
      trigger_name = string
      trigger_target_arn = string
    })), [])
    auto_rollback_configuration = optional(object({
      enabled = optional(bool, null)
      events = optional(list(string), [])
    }), {})
    alarm_configuration = optional(object({
      alarms = optional(list(string), [])
      enabled = optional(bool, null)
      ignore_poll_alarm_failure = optional(bool, null)
    }), {})
    auto_scaling_groups = optional(list(string), [])
    deployment_config_name = optional(string, null)
    ec2_tag_set = optional(list(object({
      ec2_tag_filter = list(object({
        key = optional(string, null)
        type = optional(string, null)
        value = optional(string, null)
      }))
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "codedeploy_deployment_configs" {
  description = "Map of CodeDeploy deployment configs to create"
  type = map(object({
    deployment_config_name = string
    compute_platform = optional(string, "Server")
    minimum_healthy_hosts = optional(object({
      type = optional(string, null)
      value = optional(number, null)
    }), {})
    traffic_routing_config = optional(object({
      type = optional(string, null)
      time_based_canary = optional(object({
        interval = optional(number, null)
        percentage = optional(number, null)
      }), {})
      time_based_linear = optional(object({
        interval = optional(number, null)
        percentage = optional(number, null)
      }), {})
    }), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced CodeCommit Configuration Variables
# ==============================================================================

variable "codecommit_repositories" {
  description = "Map of CodeCommit repositories to create"
  type = map(object({
    repository_name = string
    description = optional(string, null)
    default_branch = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "codecommit_triggers" {
  description = "Map of CodeCommit triggers to create"
  type = map(object({
    repository_name = string
    trigger = list(object({
      name = string
      destination_arn = string
      custom_data = optional(string, null)
      branches = optional(list(string), [])
      events = list(string)
    }))
  }))
  default = {}
}

variable "codecommit_approval_rule_templates" {
  description = "Map of CodeCommit approval rule templates to create"
  type = map(object({
    name = string
    description = optional(string, null)
    content = string
  }))
  default = {}
}

variable "codecommit_approval_rule_template_associations" {
  description = "Map of CodeCommit approval rule template associations to create"
  type = map(object({
    approval_rule_template_name = string
    repository_name = string
  }))
  default = {}
}

# ==============================================================================
# Enhanced CodeStar Configuration Variables
# ==============================================================================

variable "codestar_connections" {
  description = "Map of CodeStar connections to create"
  type = map(object({
    name = string
    provider_type = string
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "codestar_notifications" {
  description = "Map of CodeStar notifications to create"
  type = map(object({
    detail_type = string
    event_type_ids = list(string)
    name = string
    resource = string
    targets = list(object({
      address = string
      type = optional(string, null)
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced CloudFormation Configuration Variables
# ==============================================================================

variable "cloudformation_stacks" {
  description = "Map of CloudFormation stacks to create"
  type = map(object({
    name = string
    template_body = optional(string, null)
    template_url = optional(string, null)
    parameters = optional(map(string), {})
    capabilities = optional(list(string), [])
    disable_rollback = optional(bool, null)
    notification_arns = optional(list(string), [])
    on_failure = optional(string, null)
    policy_body = optional(string, null)
    policy_url = optional(string, null)
    tags = optional(map(string), {})
    timeout_in_minutes = optional(number, null)
    iam_role_arn = optional(string, null)
    termination_protection = optional(bool, null)
  }))
  default = {}
}

variable "cloudformation_stack_sets" {
  description = "Map of CloudFormation stack sets to create"
  type = map(object({
    name = string
    template_body = optional(string, null)
    template_url = optional(string, null)
    parameters = optional(map(string), {})
    capabilities = optional(list(string), [])
    description = optional(string, null)
    execution_role_name = optional(string, null)
    administration_role_arn = optional(string, null)
    permission_model = optional(string, "SELF_MANAGED")
    auto_deployment = optional(object({
      enabled = optional(bool, null)
      retain_stacks_on_account_removal = optional(bool, null)
    }), {})
    call_as = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "cloudformation_stack_set_instances" {
  description = "Map of CloudFormation stack set instances to create"
  type = map(object({
    stack_set_name = string
    account_id = optional(string, null)
    region = optional(string, null)
    deployment_targets = optional(object({
      organizational_unit_ids = optional(list(string), [])
    }), {})
    parameter_overrides = optional(map(string), {})
    operation_preferences = optional(object({
      max_concurrent_count = optional(number, null)
      max_concurrent_percentage = optional(number, null)
      failure_tolerance_count = optional(number, null)
      failure_tolerance_percentage = optional(number, null)
      region_concurrency_type = optional(string, null)
      region_order = optional(list(string), [])
    }), {})
    call_as = optional(string, null)
  }))
  default = {}
}

# ==============================================================================
# Enhanced EventBridge Configuration Variables
# ==============================================================================

variable "eventbridge_buses" {
  description = "Map of EventBridge event buses to create"
  type = map(object({
    name = string
    event_source_name = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "eventbridge_rules" {
  description = "Map of EventBridge rules to create"
  type = map(object({
    name = string
    description = optional(string, null)
    event_bus_name = optional(string, "default")
    event_pattern = optional(string, null)
    schedule_expression = optional(string, null)
    role_arn = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "eventbridge_targets" {
  description = "Map of EventBridge targets to create"
  type = map(object({
    rule = string
    event_bus_name = optional(string, "default")
    target_id = string
    arn = string
    role_arn = optional(string, null)
    input = optional(string, null)
    input_path = optional(string, null)
    input_transformer = optional(object({
      input_paths = map(string)
      input_template = string
    }), {})
    retry_policy = optional(object({
      maximum_retry_attempts = optional(number, null)
    }), {})
    dead_letter_config = optional(object({
      arn = optional(string, null)
    }), {})
    ecs_target = optional(object({
      task_count = optional(number, null)
      task_definition_arn = string
      launch_type = optional(string, null)
      network_configuration = optional(object({
        subnets = list(string)
        security_groups = optional(list(string), [])
        assign_public_ip = optional(bool, null)
      }), {})
      platform_version = optional(string, null)
      group = optional(string, null)
    }), {})
    batch_target = optional(object({
      job_definition = string
      job_name = string
      array_size = optional(number, null)
      job_attempts = optional(number, null)
    }), {})
    kinesis_target = optional(object({
      partition_key_path = optional(string, null)
    }), {})
    sqs_target = optional(object({
      message_group_id = optional(string, null)
    }), {})
    http_target = optional(object({
      path_parameter_values = optional(list(string), [])
      header_parameters = optional(map(string), {})
      query_string_parameters = optional(map(string), {})
    }), {})
    redshift_target = optional(object({
      database = string
      db_user = optional(string, null)
      secrets_manager_arn = optional(string, null)
      sql = optional(string, null)
      statement_name = optional(string, null)
      with_event = optional(bool, null)
    }), {})
    sagemaker_pipeline_target = optional(object({
      pipeline_parameter_list = optional(list(object({
        name = string
        value = string
      })), [])
    }), {})
    step_functions_target = optional(object({
      input = optional(string, null)
      input_path = optional(string, null)
    }), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced SSM Configuration Variables
# ==============================================================================

variable "ssm_parameters" {
  description = "Map of SSM parameters to create"
  type = map(object({
    name = string
    description = optional(string, null)
    type = string
    value = string
    tier = optional(string, "Standard")
    key_id = optional(string, null)
    overwrite = optional(bool, null)
    allowed_pattern = optional(string, null)
    data_type = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "ssm_documents" {
  description = "Map of SSM documents to create"
  type = map(object({
    name = string
    content = string
    document_type = optional(string, "Command")
    document_format = optional(string, "JSON")
    target_type = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "ssm_maintenance_windows" {
  description = "Map of SSM maintenance windows to create"
  type = map(object({
    name = string
    description = optional(string, null)
    schedule = string
    duration = number
    cutoff = number
    allow_unassociated_targets = optional(bool, null)
    enabled = optional(bool, null)
    end_date = optional(string, null)
    schedule_timezone = optional(string, null)
    start_date = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "ssm_maintenance_window_targets" {
  description = "Map of SSM maintenance window targets to create"
  type = map(object({
    window_id = string
    name = optional(string, null)
    description = optional(string, null)
    resource_type = string
    targets = list(object({
      key = string
      values = list(string)
    }))
    owner_information = optional(string, null)
  }))
  default = {}
}

variable "ssm_maintenance_window_tasks" {
  description = "Map of SSM maintenance window tasks to create"
  type = map(object({
    window_id = string
    task_arn = string
    task_type = string
    service_role_arn = string
    name = optional(string, null)
    description = optional(string, null)
    priority = optional(number, null)
    max_concurrency = optional(string, null)
    max_errors = optional(string, null)
    targets = optional(list(object({
      key = string
      values = list(string)
    })), [])
    task_invocation_parameters = optional(object({
      automation_parameters = optional(object({
        document_version = optional(string, null)
        parameters = optional(list(object({
          name = string
          values = list(string)
        })), [])
      }), {})
      lambda_parameters = optional(object({
        client_context = optional(string, null)
        payload = optional(string, null)
        qualifier = optional(string, null)
      }), {})
      run_command_parameters = optional(object({
        comment = optional(string, null)
        document_hash = optional(string, null)
        document_hash_type = optional(string, null)
        notification_config = optional(object({
          notification_arn: optional(string, null)
          notification_events: optional(list(string), [])
          notification_type: optional(string, null)
        }), {})
        output_s3_bucket = optional(string, null)
        output_s3_key_prefix = optional(string, null)
        parameters = optional(map(string), {})
        service_role_arn = optional(string, null)
        timeout_seconds = optional(number, null)
      }), {})
      step_functions_parameters = optional(object({
        input = optional(string, null)
        name = optional(string, null)
      }), {})
    }), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced Systems Manager Configuration Variables
# ==============================================================================

variable "ssm_automation_documents" {
  description = "Map of SSM automation documents to create"
  type = map(object({
    name = string
    content = string
    document_type = optional(string, "Automation")
    document_format = optional(string, "JSON")
    target_type = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "ssm_patch_baselines" {
  description = "Map of SSM patch baselines to create"
  type = map(object({
    name = string
    description = optional(string, null)
    operating_system = optional(string, "WINDOWS")
    approved_patches = optional(list(string), [])
    rejected_patches = optional(list(string), [])
    approved_patches_compliance_level = optional(string, "UNSPECIFIED")
    approved_patches_enable_non_security = optional(bool, null)
    rejected_patches_action = optional(string, "ALLOW_AS_DEPENDENCY")
    global_filter = optional(list(object({
      key = string
      values = list(string)
    })), [])
    approval_rule = optional(list(object({
      approve_after_days = number
      approve_until_date = optional(string, null)
      compliance_level = optional(string, "UNSPECIFIED")
      enable_non_security = optional(bool, null)
      patch_filter = list(object({
        key = string
        values = list(string)
      }))
    })), [])
    source = optional(list(object({
      name = string
      products = list(string)
      configuration = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "ssm_activation" {
  description = "Map of SSM activations to create"
  type = map(object({
    description = optional(string, null)
    expiration_date = optional(string, null)
    iam_role = string
    registration_limit = optional(number, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced CloudWatch Configuration Variables
# ==============================================================================

variable "cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups to create"
  type = map(object({
    name = string
    retention_in_days = optional(number, null)
    kms_key_id = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "cloudwatch_metric_alarms" {
  description = "Map of CloudWatch metric alarms to create"
  type = map(object({
    alarm_name = string
    comparison_operator = string
    evaluation_periods = number
    metric_name = string
    namespace = string
    period = number
    statistic = string
    threshold = number
    alarm_description = optional(string, null)
    alarm_actions = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    ok_actions = optional(list(string), [])
    unit = optional(string, null)
    extended_statistic = optional(string, null)
    treat_missing_data = optional(string, "missing")
    evaluate_low_sample_count_percentiles = optional(string, null)
    threshold_metric_id = optional(string, null)
    datapoints_to_alarm = optional(number, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "cloudwatch_dashboards" {
  description = "Map of CloudWatch dashboards to create"
  type = map(object({
    dashboard_name = string
    dashboard_body = string
  }))
  default = {}
}

# ==============================================================================
# Enhanced Security Configuration Variables
# ==============================================================================

variable "security_config" {
  description = "Security configuration for DevOps"
  type = object({
    enable_cloudtrail = optional(bool, true)
    enable_config = optional(bool, true)
    enable_guardduty = optional(bool, false)
    enable_macie = optional(bool, false)
    enable_security_hub = optional(bool, false)
    enable_iam_access_analyzer = optional(bool, false)
    enable_cloudwatch_logs_encryption = optional(bool, true)
    enable_s3_bucket_encryption = optional(bool, true)
    enable_rds_encryption = optional(bool, true)
    enable_ebs_encryption = optional(bool, true)
    enable_kms_key_rotation = optional(bool, true)
    enable_vpc_flow_logs = optional(bool, true)
    enable_network_firewall = optional(bool, false)
    enable_waf = optional(bool, false)
    enable_shield = optional(bool, false)
    enable_secrets_manager = optional(bool, true)
    enable_parameter_store_encryption = optional(bool, true)
    enable_cross_account_access = optional(bool, false)
    enable_least_privilege_access = optional(bool, true)
    enable_multi_factor_auth = optional(bool, false)
    enable_session_manager = optional(bool, true)
    enable_aws_backup = optional(bool, false)
    enable_disaster_recovery = optional(bool, false)
  })
  default = {}
}

# ==============================================================================
# Enhanced Monitoring Configuration Variables
# ==============================================================================

variable "monitoring_config" {
  description = "Monitoring configuration for DevOps"
  type = object({
    enable_cloudwatch_monitoring = optional(bool, true)
    enable_cloudwatch_logs = optional(bool, true)
    enable_cloudwatch_metrics = optional(bool, true)
    enable_cloudwatch_alarms = optional(bool, true)
    enable_cloudwatch_dashboard = optional(bool, true)
    enable_cloudwatch_insights = optional(bool, false)
    enable_cloudwatch_anomaly_detection = optional(bool, false)
    enable_cloudwatch_rum = optional(bool, false)
    enable_cloudwatch_evidently = optional(bool, false)
    enable_cloudwatch_application_signals = optional(bool, false)
    enable_cloudwatch_synthetics = optional(bool, false)
    enable_cloudwatch_contributor_insights = optional(bool, false)
    enable_cloudwatch_metric_streams = optional(bool, false)
    enable_cloudwatch_metric_filters = optional(bool, false)
    enable_cloudwatch_log_groups = optional(bool, true)
    enable_cloudwatch_log_streams = optional(bool, true)
    enable_cloudwatch_log_subscriptions = optional(bool, false)
    enable_cloudwatch_log_insights = optional(bool, false)
    enable_cloudwatch_log_metric_filters = optional(bool, false)
    enable_cloudwatch_log_destinations = optional(bool, false)
    enable_cloudwatch_log_queries = optional(bool, false)
    enable_cloudwatch_log_analytics = optional(bool, false)
    enable_cloudwatch_log_visualization = optional(bool, false)
    enable_cloudwatch_log_reporting = optional(bool, false)
    enable_cloudwatch_log_archiving = optional(bool, false)
    enable_cloudwatch_log_backup = optional(bool, false)
    enable_cloudwatch_log_retention = optional(bool, true)
    enable_cloudwatch_log_encryption = optional(bool, true)
    enable_cloudwatch_log_access_logging = optional(bool, false)
    enable_cloudwatch_log_audit_logging = optional(bool, false)
    enable_cloudwatch_log_compliance_logging = optional(bool, false)
    enable_cloudwatch_log_security_logging = optional(bool, false)
    enable_cloudwatch_log_performance_logging = optional(bool, true)
    enable_cloudwatch_log_business_logging = optional(bool, false)
    enable_cloudwatch_log_operational_logging = optional(bool, true)
    enable_cloudwatch_log_debug_logging = optional(bool, false)
    enable_cloudwatch_log_trace_logging = optional(bool, false)
    enable_cloudwatch_log_error_logging = optional(bool, true)
    enable_cloudwatch_log_warning_logging = optional(bool, true)
    enable_cloudwatch_log_info_logging = optional(bool, true)
    enable_cloudwatch_log_debug_logging = optional(bool, false)
    enable_cloudwatch_log_verbose_logging = optional(bool, false)
    enable_cloudwatch_log_silent_logging = optional(bool, false)
  })
  default = {}
} 