#------------------------------------------------------------------------------
# Terraform CI/CD Pipeline Template
#
# This module defines a CI/CD pipeline for Terraform code using AWS services:
# - CodeCommit for source control
# - CodeBuild for validation
# - CodePipeline for orchestration
# - S3 for artifact storage
# - KMS and IAM for security and access control
#
# Author: <Your Name>
# Created: <Date>
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }
}

# ----------------------------------
# Common Tags for All AWS Resources
# ----------------------------------
locals {
  common_tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}

# ----------------------
# KMS for CodePipeline
# ----------------------
module "codepipeline_kms" {
  source                = "./modules/kms"
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  tags                  = local.common_tags
}

# ----------------------
# IAM Role for CodePipeline
# ----------------------
module "codepipeline_iam_role" {
  source                     = "./modules/iam-role"
  project_name               = var.project_name
  create_new_role            = var.create_new_role
  codepipeline_iam_role_name = var.create_new_role == true ? "${var.project_name}-codepipeline-role" : var.codepipeline_iam_role_name
  source_repository_name     = var.source_repo_name
  kms_key_arn                = module.codepipeline_kms.arn
  s3_bucket_arn              = module.s3_artifacts_bucket.arn
  tags                       = local.common_tags
}

# ----------------------
# S3 Bucket for Artifacts
# ----------------------
module "s3_artifacts_bucket" {
  source                = "./modules/s3"
  project_name          = var.project_name
  kms_key_arn           = module.codepipeline_kms.arn
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  tags                  = local.common_tags
}

# -----------------------------------------
# CodeCommit Repository for Infra Source
# -----------------------------------------
module "codecommit_infrastructure_source_repo" {
  source                    = "./modules/codecommit"
  create_new_repo           = var.create_new_repo
  source_repository_name    = var.source_repo_name
  source_repository_branch  = var.source_repo_branch
  repo_approvers_arn        = var.repo_approvers_arn
  kms_key_arn               = module.codepipeline_kms.arn
  tags                      = local.common_tags
}

# ----------------------------
# CodeBuild Project for Linting & Validation
# ----------------------------
module "codebuild_terraform" {
  depends_on                          = [module.codecommit_infrastructure_source_repo]
  source                              = "./modules/codebuild"
  project_name                        = var.project_name
  role_arn                            = module.codepipeline_iam_role.role_arn
  s3_bucket_name                      = module.s3_artifacts_bucket.bucket
  build_projects                      = var.build_projects
  build_project_source                = var.build_project_source
  builder_compute_type                = var.builder_compute_type
  builder_image                       = var.builder_image
  builder_image_pull_credentials_type = var.builder_image_pull_credentials_type
  builder_type                        = var.builder_type
  kms_key_arn                         = module.codepipeline_kms.arn
  tags                                = local.common_tags
}

# -----------------------------------------------
# CodePipeline to Orchestrate the Whole Process
# -----------------------------------------------
module "codepipeline_terraform" {
  depends_on          = [module.codebuild_terraform, module.s3_artifacts_bucket]
  source              = "./modules/codepipeline"
  project_name        = var.project_name
  source_repo_name    = var.source_repo_name
  source_repo_branch  = var.source_repo_branch
  s3_bucket_name      = module.s3_artifacts_bucket.bucket
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  stages              = var.stage_input
  kms_key_arn         = module.codepipeline_kms.arn
  tags                = local.common_tags
}
