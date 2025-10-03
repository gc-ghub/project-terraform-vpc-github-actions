# Terraform AWS VPC — project-terraform-vpc-github-actions

This repo provisions an AWS VPC and networking infrastructure using Terraform, and integrates with GitHub Actions to automate **init / plan / (optionally) apply** flows.

## Table of Contents

- [Prerequisites](#prerequisites)  
- [Repository structure](#repository-structure)  
- [Local development flow](#local-development-flow)  
- [Remote backend (S3 + DynamoDB)](#remote-backend-s3--dynamodb)  
- [GitHub Actions CI/CD](#github-actions-cicd)  
- [Required GitHub Secrets / IAM Setup](#required-github-secrets--iam-setup)  
- [Variables & Example tfvars](#variables--example-tfvars)  
- [Outputs](#outputs)  
- [Testing & Validation](#testing--validation)  
- [Destroy / Cleanup](#destroy--cleanup)  
- [Cost & Security Notes](#cost--security-notes)  
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- AWS account with permissions to create VPCs, subnets, IGW, route tables, NAT gateways, Elastic IPs, etc.  
- Terraform (version 1.x recommended) installed locally  
- AWS CLI installed (helps with backend setup and verification)  
- Git, and a GitHub repository where Actions are enabled  
- Optional but recommended: `tflint`, `tfsec`

---

## Repository structure (example)

```
.
├── Terraform_VPC/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── … (maybe modules or subdirectories)
├── .github/
│   └── workflows/
│       └── terraform.yml (or similar)
└── README.md
```

---

## Local development flow

1. Clone the repo and go into the Terraform folder:

```bash
git clone https://github.com/gc-ghub/project-terraform-vpc-github-actions.git
cd project-terraform-vpc-github-actions/Terraform_VPC
```

2. Create a `terraform.tfvars` (or use `-var` flags) with values for your variables. Example (replace variable names with your actual ones):

```hcl
# terraform.tfvars
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
region = "us-east-1"

# optional additional config
enable_nat = true
resource_tags = {
  Environment = "dev"
  Owner       = "team-a"
}
```

3. Initialize Terraform (if using remote backend, supply backend configs):

```bash
terraform init
```

Or with backend settings:

```bash
terraform init \
  -backend-config="bucket=my-state-bucket" \
  -backend-config="key=vpc/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=terraform-locks" \
  -backend-config="encrypt=true"
```

4. Run formatting, validation, and plan:

```bash
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
```

5. Apply the plan:

```bash
terraform apply tfplan
# or
terraform apply -auto-approve
```

---

## Remote backend (S3 + DynamoDB)

Create S3 bucket (enable versioning & encryption) and DynamoDB table for state locking:

```bash
aws s3api create-bucket --bucket my-state-bucket --region us-east-1 \
  --create-bucket-configuration LocationConstraint=us-east-1

aws s3api put-bucket-versioning --bucket my-state-bucket --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket my-state-bucket \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

Configure backend in Terraform or via `-backend-config` flags.

---

## GitHub Actions CI/CD

Example workflow:

```yaml
name: Terraform

on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: '1.5.0'

      - uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - run: |
          terraform init \
            -backend-config="bucket=${{ secrets.TF_STATE_BUCKET }}" \
            -backend-config="key=vpc/terraform.tfstate" \
            -backend-config="dynamodb_table=${{ secrets.TF_LOCK_TABLE }}"

      - run: terraform plan -input=false -out=tfplan
```

Optionally add a job for `apply` with manual approval or restricted to main branch.

---

## Required GitHub Secrets / IAM Setup

- `AWS_ACCESS_KEY_ID`  
- `AWS_SECRET_ACCESS_KEY`  
- `AWS_REGION`  
- `TF_STATE_BUCKET`  
- `TF_LOCK_TABLE`

Minimal IAM actions recommended for CI:
- `ec2:*` (or narrower) for VPC/subnet/route/NAT gateway resources
- `s3:GetObject`, `s3:PutObject`, `s3:ListBucket` for state bucket
- `dynamodb:PutItem`, `GetItem`, `DeleteItem`, `UpdateItem` for lock table

Prefer OIDC for short-lived credentials.

---

## Variables & Example tfvars

Replace with your actual variables from `variables.tf`.

| Variable | Type | Default / Required | Description |
|---|---|---|---|
| `vpc_cidr` | string | required | CIDR block for VPC |
| `public_subnet_cidrs` | list(string) | required | List of public subnet CIDRs |
| `private_subnet_cidrs` | list(string) | required | List of private subnet CIDRs |
| `region` | string | optional | AWS region |
| `enable_nat` | bool | default=false | Create NAT gateways |
| `resource_tags` | map(string) | {} | Tags for resources |

Example `terraform.tfvars`:

```hcl
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
region = "us-east-1"
enable_nat = true
resource_tags = {
  Environment = "dev"
  Owner       = "team-a"
}
```

---

## Outputs

Typical outputs (replace with your actual outputs):
- `vpc_id`  
- `public_subnet_ids`  
- `private_subnet_ids`  
- `public_route_table_ids`  
- `private_route_table_ids`

View outputs:
```bash
terraform output
terraform output -json
```

---

## Testing & Validation

```bash
terraform fmt -recursive
terraform validate
# optional
# tflint
# tfsec
```

---

## Destroy / Cleanup

```bash
terraform destroy
```

---

## Cost & Security Notes

- NAT gateways and Elastic IPs incur hourly and data transfer costs.  
- S3 and DynamoDB for state have minimal charges.  
- Avoid long-lived IAM credentials; use OIDC or short-term roles.  
- Secure remote state bucket access.

---

## Troubleshooting

- **AccessDenied** → check IAM permissions.  
- **BucketAlreadyExists** → S3 bucket name must be unique.  
- **Backend mismatch** → run `terraform init -reconfigure`.  
- **State lock stuck** → inspect DynamoDB lock table carefully.

