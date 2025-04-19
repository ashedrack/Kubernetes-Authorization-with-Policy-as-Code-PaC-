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

## 🌟 Comprehensive Guide

## 🤝 Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## 📄 License
This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.


## 📢 Spread the Word
Share your journey with your network and tag me, [Abdihakim Said](https://www.linkedin.com/in/said-devops/), when you post your blogs on LinkedIn. Let's learn together!

Happy learning and blogging! 🌟
