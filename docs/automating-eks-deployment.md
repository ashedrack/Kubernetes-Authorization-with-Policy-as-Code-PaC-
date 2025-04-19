# Automating EKS Cluster Deployment with Terraform and GitHub Actions: A Complete Guide

*This guide is an enhanced version of the excellent work originally published by [Aman Pathak](https://medium.com/devops-dev/introduction-ab466a03c714). I've built upon his foundation to provide additional insights and optimizations.*

## Introduction

Managing Kubernetes clusters efficiently is crucial for any organization. This guide will walk you through setting up a production-ready Amazon EKS (Elastic Kubernetes Service) cluster using Terraform and automating its deployment with GitHub Actions. We'll cover everything from infrastructure setup to continuous deployment practices.

## Architecture Overview

![EKS Architecture](https://raw.githubusercontent.com/ashedrack/Automate-EKS-CREATION-WITH-GITHUBACTIONS/main/assets/Presentation1.gif)

The architecture implements a production-grade EKS cluster with:
- Multi-AZ deployment across public and private subnets
- Mix of On-Demand and Spot instances for cost optimization
- Secure networking with NAT Gateways
- OIDC integration for pod IAM roles

## Prerequisites

Before we begin, ensure you have:
- An AWS account with appropriate permissions
- GitHub account
- Basic understanding of Terraform and Kubernetes
- AWS CLI installed locally

## Infrastructure as Code Setup

### Setting up the Backend Infrastructure

One of the most important aspects of managing infrastructure as code is having a reliable and secure state management system. We'll use AWS S3 for state storage and DynamoDB for state locking.

```bash
# Create DynamoDB table for state locking (On-Demand pricing)
aws dynamodb create-table \
  --table-name Lock-Files \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1

# Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket dev-aj-tf-bucket \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket dev-aj-tf-bucket \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket dev-aj-tf-bucket \
  --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
```

### Cost Optimization

A key consideration in my setup is cost management. I've implemented several cost-optimization strategies:

1. **DynamoDB On-Demand Pricing**:
   - Pay only for actual usage
   - No minimum capacity charges
   - Perfect for sporadic Terraform operations
   - Typical cost: < $1/month

2. **S3 State Storage**:
   - Minimal storage costs for state files
   - Versioning enabled for safety
   - Typical cost: < $1/month

## GitHub Actions Workflow

Our automation pipeline is built using GitHub Actions. The workflow is designed to be both automated and manual, with safety checks at each stage.

### Workflow Triggers

```yaml
name: 'Terraform'

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
  workflow_dispatch:
    inputs:
      tfvars_file:
        description: 'Path to the .tfvars file'
        required: true
        default: 'variables.tfvars'
      action:
        type: choice
        description: 'Action to perform'
        options:
        - plan
        - apply
        - destroy
        required: true
        default: 'apply'
```

### Environment Setup

```yaml
env:
  AWS_REGION: us-east-1
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

permissions:
  contents: read
```

### Job Structure

The workflow is divided into sequential jobs for better control and visibility:

1. **Checkout Repository**:
```yaml
CheckOut-Repo:
  runs-on: ubuntu-latest
  steps:
    - name: Checkout
      uses: actions/checkout@v4
```

2. **Setup Terraform**:
```yaml
Setting-Up-Terraform:
  needs: CheckOut-Repo
  steps:
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v1
      with:
        terraform_version: 1.9.3
```

3. **Initialize and Validate**:
```yaml
Terraform-Initializing:
  needs: Setting-Up-Terraform
  steps:
    - name: Terraform Init
      working-directory: eks
      run: terraform init

Terraform-Formatting-Validating:
  needs: Terraform-Initializing
  steps:
    - name: Terraform Format
      run: terraform fmt
    - name: Terraform Validate
      run: terraform validate
```

4. **Execute Terraform Actions**:
```yaml
Terraform-Action:
  needs: Terraform-Formatting-Validating
  steps:
    - name: Terraform Plan
      if: github.event.inputs.action == 'plan'
      run: |
        terraform plan -var-file=${{ github.event.inputs.tfvars_file }} -input=false

    - name: Terraform Apply
      if: github.event.inputs.action == 'apply'
      run: |
        terraform apply -auto-approve -var-file=${{ github.event.inputs.tfvars_file }} -input=false

    - name: Terraform Destroy
      if: github.event.inputs.action == 'destroy'
      run: |
        terraform destroy -auto-approve -var-file=${{ github.event.inputs.tfvars_file }} -input=false
```
```

### Workflow Structure

The workflow is divided into several jobs:

1. **Checkout Repository**: Initial setup and code retrieval
2. **Setting Up Terraform**: Installing and configuring Terraform
3. **Terraform Initialization**: Setting up the working directory
4. **Formatting and Validation**: Ensuring code quality
5. **Terraform Action**: Executing the requested operation

### Security Considerations

We've implemented several security best practices:

1. **State Encryption**:
   - S3 server-side encryption
   - Secure state file storage
   - Protected sensitive information

2. **Access Control**:
   - GitHub Secrets for AWS credentials
   - Least privilege principle
   - Environment-specific configurations

## EKS Cluster Configuration

Our EKS cluster is configured with production-ready settings:

### 1. Node Group Strategy

We implement a hybrid node group approach for optimal cost-performance balance:

```hcl
# On-Demand Node Group for critical workloads
resource "aws_eks_node_group" "ondemand-node" {
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster-name}-on-demand-nodes"
  node_role_arn   = aws_iam_role.eks-nodegroup-role[0].arn

  scaling_config {
    desired_size = var.desired_capacity_on_demand
    min_size     = var.min_capacity_on_demand
    max_size     = var.max_capacity_on_demand
  }

  instance_types = var.ondemand_instance_types
  capacity_type  = "ON_DEMAND"
}

# Spot Node Group for cost optimization
resource "aws_eks_node_group" "spot-node" {
  cluster_name    = aws_eks_cluster.eks[0].name
  node_group_name = "${var.cluster-name}-spot-nodes"
  
  scaling_config {
    desired_size = var.desired_capacity_spot
    min_size     = var.min_capacity_spot
    max_size     = var.max_capacity_spot
  }

  instance_types = var.spot_instance_types
  capacity_type  = "SPOT"
}
```

### 2. Networking Configuration

Implements a secure VPC setup with public and private subnets:

```hcl
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr-block
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "private-subnet" {
  count             = var.pri-subnet-count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.pri-cidr-block, count.index)
  availability_zone = element(var.pri-availability-zone, count.index)

  tags = {
    "kubernetes.io/cluster/${local.cluster-name}" = "owned"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
```

### 3. Security Implementation

Secured with IAM roles and security groups:

```hcl
resource "aws_security_group" "eks-cluster-sg" {
  name        = var.eks-sg
  description = "EKS cluster security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Should be restricted in production
  }
}
```

### 4. OIDC Integration

Enables pod-level IAM roles:

```hcl
resource "aws_iam_openid_connect_provider" "eks-oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks-certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks[0].identity[0].oidc[0].issuer
}
```

### 5. Add-ons Management

Manages essential EKS add-ons:

```hcl
resource "aws_eks_addon" "eks-addons" {
  for_each = { for idx, addon in var.addons : idx => addon }
  
  cluster_name  = aws_eks_cluster.eks[0].name
  addon_name    = each.value.name
  addon_version = each.value.version
}
```

## Continuous Deployment

The GitHub Actions workflow enables continuous deployment by:

1. Automatically planning changes on pull requests
2. Applying changes when merging to main
3. Supporting manual interventions when needed

## Cleanup and Maintenance

When you need to clean up resources:

```bash
# Empty S3 bucket
aws s3 rm s3://dev-aj-tf-bucket --recursive

# Delete S3 bucket
aws s3api delete-bucket \
  --bucket dev-aj-tf-bucket \
  --region us-east-1

# Delete DynamoDB table
aws dynamodb delete-table \
  --table-name Lock-Files \
  --region us-east-1
```

## Best Practices and Tips

1. **State Management**:
   - Always use remote state
   - Enable versioning
   - Implement state locking

2. **Security**:
   - Encrypt sensitive data
   - Use IAM roles
   - Regular security audits

3. **Cost Management**:
   - Monitor resource usage
   - Use auto-scaling
   - Implement tagging strategy

## Conclusion

Automating EKS deployment with Terraform and GitHub Actions provides a robust, secure, and efficient way to manage Kubernetes infrastructure. This setup ensures:

- Consistent environments
- Version-controlled infrastructure
- Automated deployments
- Cost-effective operations
- Secure state management

The combination of infrastructure as code and CI/CD creates a powerful platform for modern cloud-native applications.

## Directory Structure

```
├── module/
│   ├── gather.tf       # OIDC and TLS certificate configuration
│   ├── vpc.tf         # VPC, subnets, and networking components
│   ├── iam.tf         # IAM roles and policies
│   ├── eks.tf         # EKS cluster and node groups
│   └── variables.tf    # Module variables
├── eks/
│   ├── backend.tf     # S3 and DynamoDB backend configuration
│   ├── main.tf        # Main module instantiation
│   ├── variables.tf   # Input variables
│   └── dev.tfvars     # Environment-specific values
└── .github/
    └── workflows/
        └── terraform.yml  # GitHub Actions workflow
```

## Resources

- [Original Article by Aman Pathak](https://medium.com/devops-dev/introduction-ab466a03c714)
- [Terraform Documentation](https://www.terraform.io/docs)
- [EKS Documentation](https://docs.aws.amazon.com/eks)
- [GitHub Actions](https://docs.github.com/en/actions)
- [AWS CLI Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/index.html)

## Acknowledgments

Special thanks to Aman Pathak for the original implementation and detailed walkthrough of the EKS cluster setup. This guide builds upon his work by adding additional cost optimization strategies, security enhancements, and improved automation workflows.
