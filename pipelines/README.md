# Azure DevOps CI/CD Pipelines

Complete CI/CD automation for Terraform infrastructure deployment.

## Pipeline Overview

1. terraform-plan.yml - Validates and plans infrastructure changes
2. terraform-apply.yml - Applies infrastructure changes
3. terraform-destroy.yml - Destroys infrastructure
4. validate-terraform.yml - Code quality checks

## Prerequisites

- Azure DevOps service connection
- Variable group: terraform-prod-variables

## Usage

Run pipelines from Azure DevOps UI or CLI.

v1.0.0 (November 2025)
