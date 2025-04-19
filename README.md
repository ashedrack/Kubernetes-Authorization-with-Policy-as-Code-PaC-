# 🚀 Configuring Production-Ready EKS Clusters with Terraform and GitHub Actions
[![LinkedIn](https://img.shields.io/badge/Connect%20with%20me%20on-LinkedIn-blue.svg)](https://www.linkedin.com/in/said-devops/)
[![Medium](https://img.shields.io/badge/Medium-12100E?style=for-the-badge&logo=medium&logoColor=white)](https://medium.com/@said-devops)
[![GitHub](https://img.shields.io/github/stars/AmanPathak-DevOps.svg?style=social)](https://github.com/abdihakim-said)
[![AWS](https://img.shields.io/badge/AWS-%F0%9F%9B%A1-orange)](https://aws.amazon.com)
[![Terraform](https://img.shields.io/badge/Terraform-%E2%9C%A8-lightgrey)](https://www.terraform.io)

![EKS- GitHub Actions- Terraform](assets/Presentation1.gif)

Welcome to the repository for **Configuring Production-Ready EKS Clusters with Terraform and Automating with GitHub Actions**! This repository accompanies my blog post and demonstrates the practical steps to set up and automate an EKS cluster.

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

## 🌟 Overview
This project covers:
- **Infrastructure as Code (IaC)**: Use Terraform to define and manage your EKS cluster.
- **CI/CD Automation**: Leverage GitHub Actions to automate deployments.

# EKS Terraform with Policy-as-Code (PaC)

This project demonstrates how to implement a production-ready EKS cluster with advanced authorization using Policy-as-Code (PaC). It combines infrastructure automation via Terraform with modern authorization patterns using OPA, OPAL, and Permit.io.

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
├── policies/                    # OPA Rego policies
│   ├── rbac/                   # Role-based policies
│   │   ├── image_policy.rego
│   │   ├── network_policy.rego
│   │   └── pod_security.rego
│   ├── rebac/                  # Relationship-based policies
│   │   └── account_access.rego
│   └── tests/                  # Policy unit tests
├── infrastructure/             # Infrastructure code
│   ├── terraform/             # Terraform modules
│   │   └── opa.tf            # OPA deployment
│   └── kubernetes/           # K8s manifests
│       ├── opal-config.yaml
│       └── permit-config.yaml
├── examples/                   # Example applications
│   └── permit-app/           # FastAPI + Permit.io demo
└── docs/                      # Documentation
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- kubectl >= 1.20
- OPA CLI
- Python >= 3.11 (for example app)

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

## Acknowledgments

- Based on the original work by [Aman Pathak](https://github.com/ashedrack)
- Inspired by best practices from financial institutions
- Uses open-source tools: OPA, OPAL, and Permit.io

## License

MIT

## 🤝 Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## 📄 License
This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.


## 📢 Spread the Word
Share your journey with your network and tag me, [Abdihakim Said](https://www.linkedin.com/in/said-devops/), when you post your blogs on LinkedIn. Let's learn together!

Happy learning and blogging! 🌟
