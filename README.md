# 🚀 Configuring Production-Ready EKS Clusters with Terraform and GitHub Actions
[![LinkedIn](https://img.shields.io/badge/Connect%20with%20me%20on-LinkedIn-blue.svg)](https://www.linkedin.com/in/said-devops/)
[![Medium](https://img.shields.io/badge/Medium-12100E?style=for-the-badge&logo=medium&logoColor=white)](https://medium.com/@said-devops)
[![GitHub](https://img.shields.io/github/stars/AmanPathak-DevOps.svg?style=social)](https://github.com/abdihakim-said)
[![AWS](https://img.shields.io/badge/AWS-%F0%9F%9B%A1-orange)](https://aws.amazon.com)
[![Terraform](https://img.shields.io/badge/Terraform-%E2%9C%A8-lightgrey)](https://www.terraform.io)

![EKS- GitHub Actions- Terraform](assets/Presentation1.gif)


## 🌟 Overview
This project covers:
- **Infrastructure as Code (IaC)**: Use Terraform to define and manage your EKS cluster.
- **CI/CD Automation**: Leverage GitHub Actions to automate deployments.

# Enhancing Kubernetes Authorization with Policy-as-Code (PaC)

As we continue to evolve our EKS infrastructure automation, the next critical frontier is authorization modernization. Traditional Role-Based Access Control (RBAC) systems, while familiar, are increasingly inadequate in dynamic, multi-tenant, and compliance-heavy environments—especially in sectors like banking and fintech.

Drawing insights from leading financial institutions and frameworks like OPA, Styra DAS, OPAL, and Permit.io, we've integrated Policy-as-Code (PaC) into our EKS architecture to support Attribute-Based Access Control (ABAC) and Relationship-Based Access Control (ReBAC) at scale.

## Why Policy-as-Code?

In a Kubernetes-native architecture, externalizing authorization logic from application code to version-controlled, declarative policies enhances:

- **Security**: Enforces least-privilege access with real-time decisions
- **Auditability**: Tracks every policy change and access decision
- **Scalability**: Handles 50,000+ TPS with <5ms latency
- **Compliance**: Meets strict mandates like GDPR, PSD2, and SOX with dynamic revocation and audit readiness

## Implementation Approach

We've adopted a phased PaC implementation model, inspired by practices at leading financial institutions:

### Phase 1: Internal Infrastructure
- OPA + Rego policies enforce authorization in Terraform pipelines
- Kubernetes ValidatingWebhookConfigurations validate infrastructure deployment

### Phase 2: Platform APIs & CI/CD
- OPA sidecars deployed next to critical services
- OPAL + Kafka streams for dynamic policy updates

### Phase 3: Customer-Facing Services
- ReBAC via Permit.io for external apps
- OPA + Redis caching for ultra-low latency decisions

## Architecture Overview

The project implements a multi-layered authorization strategy:

1. **Infrastructure Layer**: OPA policies for EKS configuration validation
2. **Platform Layer**: Real-time policy updates via OPAL
3. **Application Layer**: Fine-grained access control with Permit.io

This project demonstrates how to implement a production-ready EKS cluster with advanced authorization using Policy-as-Code (PaC). It combines infrastructure automation via Terraform with modern authorization patterns using OPA, OPAL, and Permit.io.

## Architecture Overview

The project implements a multi-layered authorization strategy:

1. **Infrastructure Layer**: OPA policies for EKS configuration validation
2. **Platform Layer**: Real-time policy updates via OPAL
3. **Application Layer**: Fine-grained access control with Permit.io

## Features

### Infrastructure Security
- Pod security policies (privileged containers, resource limits)
- Network policies for namespace isolation
- Image registry validation
- Resource quota enforcement

### Authorization Patterns
- Role-Based Access Control (RBAC)
- Attribute-Based Access Control (ABAC)
- Relationship-Based Access Control (ReBAC)

### Real-Time Policy Updates
- Git-based policy management
- OPAL integration for dynamic updates
- Redis caching for performance

### Developer Experience
- FastAPI example application
- Permit.io SDK integration
- Comprehensive policy testing

## Project Structure

```plaintext
.
├── .github/                    # GitHub Actions workflows
│   └── workflows/
│       ├── opa-validation.yml  # OPA policy validation
│       └── terraform.yml       # Infrastructure deployment
├── assets/                    # Project assets and images
├── docs/                      # Documentation
│   ├── policies.md            # Generated policy documentation
│   └── medium-article.md      # Project article
├── eks/                      # EKS-specific configurations
├── examples/                  # Example applications
│   └── permit-app/           # FastAPI + Permit.io demo
├── infrastructure/           # Infrastructure code
│   ├── kubernetes/           # Kubernetes manifests
│   │   ├── opal-config.yaml  # OPAL configuration
│   │   └── permit-config.yaml # Permit.io configuration
│   └── terraform/            # Terraform modules
│       ├── eks.tf            # EKS cluster configuration
│       ├── iam.tf            # IAM roles and policies
│       ├── main.tf           # Main Terraform configuration
│       ├── opa.tf            # OPA/Gatekeeper deployment
│       ├── outputs.tf        # Output definitions
│       └── variables.tf       # Variable definitions
├── module/                   # Reusable Terraform modules
├── policies/                 # OPA Rego policies
│   ├── abac/                # Attribute-based policies
│   ├── rbac/                # Role-based policies
│   │   ├── image_policy.rego # Container image validation
│   │   ├── network_policy.rego # Network access control
│   │   └── pod_security.rego  # Pod security constraints
│   └── rebac/               # Relationship-based policies
│       └── account_access.rego # Account access control
└── tests/                   # Policy unit tests
    └── account_access_test.rego # ReBAC policy tests

```

### Key Components

1. **GitHub Actions Workflows**
   - `opa-validation.yml`: Validates OPA policies and generates documentation
   - `terraform.yml`: Manages infrastructure deployment and updates

2. **Infrastructure**
   - Terraform configurations for EKS, IAM, and OPA
   - Kubernetes manifests for policy engines and middleware

3. **Policies**
   - RBAC: Traditional role-based access control
   - ABAC: Attribute-based policies for fine-grained control
   - ReBAC: Relationship-based policies for complex access patterns

4. **Testing**
   - Unit tests for policy validation
   - Integration tests for policy combinations
   - Example applications for demonstration

5. **Documentation**
   - Auto-generated policy documentation
   - Implementation guides and articles
   - Architecture diagrams and workflows


### Prerequisites Setup Commands

```bash
# Create DynamoDB table for state locking (On-Demand pricing)
aws dynamodb create-table \
  --table-name Lock-Files \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1

# Create S3 bucket for Terraform state with versioning and encryption
aws s3api create-bucket \
  --bucket dev-aj-tf-bucket \
  --region us-east-1

# Enable versioning on the S3 bucket
aws s3api put-bucket-versioning \
  --bucket dev-aj-tf-bucket \
  --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket dev-aj-tf-bucket \
  --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
```

### Cleanup Commands
When you're done and want to clean up the infrastructure:

```bash
# First, empty the S3 bucket (required before deletion)
aws s3 rm s3://dev-aj-tf-bucket --recursive

# Delete the S3 bucket
aws s3api delete-bucket \
  --bucket dev-aj-tf-bucket \
  --region us-east-1

# Delete the DynamoDB table
aws dynamodb delete-table \
  --table-name Lock-Files \
  --region us-east-1


## 🧰 Tooling Highlights

| Tool | Role |
|------|------|
| OPA | Core policy engine with Rego DSL |
| Styra DAS | Governance and policy lifecycle management |
| OPAL | Real-time policy and data updates |
| Permit.io | Developer-friendly ReBAC platform with SDKs |

## Prerequisites

### Infrastructure Tools
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- kubectl >= 1.20

### Policy Tools
- OPA CLI
- OPAL Server/Client
- Permit.io account and API key

### Development
- Python >= 3.11 (for example app)
- Redis >= 6.0 (for policy caching)
- Kafka >= 2.8 (for policy updates)

## Quick Start

1. **Clone the repository**
```bash
git clone https://github.com/your-org/eks-terraform-pac
cd eks-terraform-pac
```

2. **Deploy Infrastructure**
```bash
cd infrastructure/terraform
terraform init
terraform apply
```

3. **Deploy OPA and OPAL**
```bash
kubectl apply -f ../kubernetes/opal-config.yaml
```

4. **Configure Permit.io**
- Create an account at [Permit.io](https://permit.io)
- Get your API key
- Update the secret in `infrastructure/kubernetes/permit-config.yaml`
```bash
kubectl apply -f ../kubernetes/permit-config.yaml
```

5. **Run Example App**
```bash
cd examples/permit-app
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows
pip install -r requirements.txt
uvicorn app:app --reload
```

## Policy Testing

```bash
# Test all policies
opa test policies/ --verbose

# Test specific policy
opa test policies/rebac/account_access.rego policies/tests/account_access_test.rego
```

## Policy Examples

### Pod Security Policy
```rego
# Deny privileged containers
deny[msg] {
    input.request.kind.kind == "Pod"
    container := input.request.object.spec.containers[_]
    container.securityContext.privileged == true
    msg := sprintf("Container '%s' must not run as privileged", [container.name])
}
```

### ReBAC Policy
```rego
# Allow parent accounts to access child accounts
allow {
    input.subject.relation == "parent"
    input.resource.type == "account"
    input.resource.child_id == input.subject.child_id
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for your changes
4. Ensure all tests pass
5. Submit a pull request



Happy learning and blogging! 🌟
