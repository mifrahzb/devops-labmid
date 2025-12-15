# Terraform Infrastructure Configuration

This directory contains Terraform configuration files for provisioning infrastructure for the PetClinic application.

## Files

- `provider.tf` - Terraform and AWS provider configuration
- `main.tf` - Main infrastructure resources (VPC, EC2, S3, Security Groups)
- `variables.tf` - Input variables
- `outputs.tf` - Output values after terraform apply
- `terraform.tfvars.example` - Example variable values

## Prerequisites

1. Install Terraform (version 1.0+)
2. Configure AWS credentials:
   - Set environment variables: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
   - Or configure AWS CLI: `aws configure`
3. Ensure you have appropriate AWS IAM permissions

## Usage

### Initialize Terraform
```bash
cd infra/terraform
terraform init
```

### Plan Infrastructure Changes (Dry Run)
```bash
terraform plan
```

### Apply Infrastructure Changes
```bash
terraform apply
```

### Destroy Infrastructure
```bash
terraform destroy
```

## Configuration

Copy `terraform.tfvars.example` to `terraform.tfvars` and customize:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

## Resources Created

- **VPC**: Virtual Private Cloud with CIDR 10.0.0.0/16
- **Internet Gateway**: For public internet access
- **Public Subnet**: Subnet with CIDR 10.0.1.0/24
- **Route Table**: Routes for internet access
- **Security Group**: Allows SSH (22) and HTTP (80) ingress
- **EC2 Instance**: t2.micro instance (Free Tier eligible)
- **S3 Bucket**: For application storage

## Notes

- Default region is `us-east-1`
- Instance type is `t2.micro` (Free Tier eligible)
- AMI is Amazon Linux 2
- This configuration is suitable for development/testing environments
