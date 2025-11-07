# Deployment Guide

Step-by-step guide for deploying infrastructure.

## Prerequisites

- Azure CLI >= 2.50.0
- Terraform >= 1.10.3
- kubectl >= 1.28.0

## Stage 1 Deployment

1. Configure variables
2. Run deploy-stage1.sh
3. Get AKS credentials
4. Discover Istio LB IP

## Stage 2 Deployment

1. Update terraform.tfvars with Istio LB IP
2. Run deploy-stage2.sh
3. Validate deployment

v1.0.0 (November 2025)
