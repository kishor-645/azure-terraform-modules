# ERP Infrastructure - Azure Terraform

Production-ready infrastructure for ERP system on Azure.

## Quick Start

1. Setup backend: ./scripts/setup-backend.sh
2. Deploy Stage 1: ./scripts/deploy-stage1.sh
3. Get Istio LB IP: ./scripts/get-istio-lb-ip.sh
4. Deploy Stage 2: ./scripts/deploy-stage2.sh

## Documentation

- DEPLOYMENT-GUIDE.md - Step-by-step deployment
- ARCHITECTURE.md - Architecture details
- TROUBLESHOOTING.md - Common issues
- COST-ESTIMATION.md - Monthly costs

## Features

- Hub-spoke network topology
- Private AKS with Istio
- Azure Firewall Premium
- PostgreSQL Flexible Server
- Centralized monitoring

## Cost

Monthly: $3,445 - $5,945 USD

v1.0.0 (November 2025)
