#------------------------------------------------------------------------------
# Terraform CI/CD Pipeline Variables
#
# These input variables configure the Terraform CI/CD pipeline components:
# CodeCommit, CodeBuild, CodePipeline, IAM, S3, and KMS.
#
# Author: <Your Name>
#------------------------------------------------------------------------------

variable "project_name" {
  description = "Unique name for this project (used as prefix for resources)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}

variable "create_new_repo" {
  description = "Whether to create a new CodeCommit repository"
  type        = bool
  default     = true
}

variable "create_new_role" {
  description = "Whether to create a new IAM role for CodePipeline"
  type        = bool
  default     = true
}

variable "codepipeline_iam_role_name" {
  description = "Name of an existing IAM role to use for CodePipeline (used if create_new_role is false)"
  type        = string
  default     = "codepipeline-role"
}

variable "source_repo_name" {
  description = "Name of the CodeCommit repository containing infrastructure code"
  type        = string
}

variable "source_repo_branch" {
  description = "Default branch in the CodeCommit repository for pipeline execution"
  type        = string
}

variable "repo_approvers_arn" {
  description = "ARN or ARN pattern for IAM user/role/group that can approve PRs"
  type        = string
}

variable "stage_input" {
  description = "List of CodePipeline stages with configuration (as maps)"
  type        = list(map(any))
}

variable "build_projects" {
  description = "List of build project names used in CodeBuild stages"
  type        = list(string)
}

variable "builder_compute_type" {
  description = "Compute type used by CodeBuild projects"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "builder_image" {
  description = "Docker image used for CodeBuild environment"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

variable "builder_type" {
  description = "Type of CodeBuild environment (e.g., LINUX_CONTAINER)"
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "builder_image_pull_credentials_type" {
  description = "Type of credentials used for pulling Docker image (e.g., CODEBUILD, SERVICE_ROLE)"
  type        = string
  default     = "CODEBUILD"
}

variable "build_project_source" {
  description = "Build source type (e.g., CODEPIPELINE, GITHUB, etc.)"
  type        = string
  default     = "CODEPIPELINE"
}
