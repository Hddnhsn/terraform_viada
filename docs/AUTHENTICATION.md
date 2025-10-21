# Authentication Guide for Terraform AWS

## Overview

This guide covers different methods to authenticate Terraform with AWS.

## Authentication Methods

### Method 1: AWS CLI Configuration (Recommended for Local Development)

#### Step 1: Install AWS CLI

**macOS:**
```bash
brew install awscli
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows:**
Download and install from: https://aws.amazon.com/cli/

#### Step 2: Configure AWS Credentials

```bash
aws configure
```

You'll be prompted for:
- **AWS Access Key ID**: Your access key
- **AWS Secret Access Key**: Your secret key
- **Default region**: e.g., `us-east-1`
- **Default output format**: `json`

This creates credentials in `~/.aws/credentials`:
```ini
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
```

And config in `~/.aws/config`:
```ini
[default]
region = us-east-1
output = json
```

#### Step 3: Test Authentication

```bash
aws sts get-caller-identity
```

Expected output:
```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-username"
}
```

### Method 2: Environment Variables

Set environment variables (useful for CI/CD):

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

For temporary credentials (with MFA):
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_SESSION_TOKEN="your-session-token"
export AWS_DEFAULT_REGION="us-east-1"
```

### Method 3: AWS Profiles

Use multiple AWS accounts/profiles:

#### Create Named Profiles

```bash
aws configure --profile viada-dev
aws configure --profile viada-prod
```

This creates:
```ini
# ~/.aws/credentials
[viada-dev]
aws_access_key_id = DEV_ACCESS_KEY
aws_secret_access_key = DEV_SECRET_KEY

[viada-prod]
aws_access_key_id = PROD_ACCESS_KEY
aws_secret_access_key = PROD_SECRET_KEY
```

#### Use Profile with Terraform

**Option A: Environment Variable**
```bash
export AWS_PROFILE=viada-dev
terraform plan
```

**Option B: Provider Configuration**

Update `providers.tf`:
```hcl
provider "aws" {
  region  = var.aws_region
  profile = "viada-dev"
  
  default_tags {
    tags = var.common_tags
  }
}
```

### Method 4: IAM Role (EC2/ECS/Lambda)

When running Terraform from AWS services:

```hcl
provider "aws" {
  region = var.aws_region
  
  # Terraform will automatically use the IAM role attached to the instance
}
```

### Method 5: Assume Role

Assuming a role in another account:

```hcl
provider "aws" {
  region = var.aws_region
  
  assume_role {
    role_arn     = "arn:aws:iam::ACCOUNT_ID:role/TerraformRole"
    session_name = "terraform-session"
  }
}
```

### Method 6: AWS SSO (Single Sign-On)

#### Configure SSO

```bash
aws configure sso
```

Follow prompts for:
- SSO start URL
- SSO region
- Account and role selection
- CLI profile name

#### Login and Use

```bash
aws sso login --profile viada-sso
export AWS_PROFILE=viada-sso
terraform plan
```

## Creating AWS IAM User for Terraform

### Step 1: Create IAM User

```bash
aws iam create-user --user-name terraform-user
```

### Step 2: Attach Policies

For full access (development only):
```bash
aws iam attach-user-policy \
  --user-name terraform-user \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

For restricted access (recommended):
```bash
# Create a custom policy (see iam-policies.tf)
aws iam attach-user-policy \
  --user-name terraform-user \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/TerraformPolicy
```

### Step 3: Create Access Keys

```bash
aws iam create-access-key --user-name terraform-user
```

Save the output securely:
```json
{
    "AccessKey": {
        "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
        "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        "Status": "Active",
        "CreateDate": "2025-01-15T12:34:56Z"
    }
}
```

## Security Best Practices

### 1. Never Commit Credentials
- ✅ Use `.gitignore` to exclude credential files
- ✅ Use environment variables or AWS profiles
- ❌ Never hardcode credentials in Terraform files

### 2. Use Minimal Permissions
- Create IAM policies with least privilege
- Use separate users/roles for dev/staging/prod

### 3. Enable MFA
```bash
aws iam enable-mfa-device \
  --user-name terraform-user \
  --serial-number arn:aws:iam::ACCOUNT_ID:mfa/terraform-user \
  --authentication-code-1 123456 \
  --authentication-code-2 789012
```

### 4. Rotate Access Keys Regularly
```bash
# Create new key
aws iam create-access-key --user-name terraform-user

# Test new key
# ...

# Delete old key
aws iam delete-access-key \
  --user-name terraform-user \
  --access-key-id OLD_ACCESS_KEY_ID
```

### 5. Use AWS Secrets Manager for Sensitive Values

```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
  # ...
}
```

## Troubleshooting

### Error: No valid credential sources

**Solution:**
```bash
# Check AWS CLI configuration
aws configure list

# Verify credentials
aws sts get-caller-identity

# Check environment variables
env | grep AWS
```

### Error: Access Denied

**Solution:**
- Verify IAM permissions
- Check if MFA is required
- Confirm you're using the correct AWS account

### Error: Region not set

**Solution:**
```bash
export AWS_DEFAULT_REGION=us-east-1
# OR
aws configure set region us-east-1
```

## CI/CD Authentication

### GitHub Actions

```yaml
# .github/workflows/terraform.yml
name: Terraform

on:
  push:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Plan
        run: terraform plan
```

### GitLab CI

```yaml
# .gitlab-ci.yml
variables:
  AWS_DEFAULT_REGION: us-east-1

terraform:
  image: hashicorp/terraform:latest
  before_script:
    - export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
    - export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
  script:
    - terraform init
    - terraform plan
```

## Testing Authentication

Use the provided script:

```bash
./scripts/test-auth.sh
```

This will verify:
- AWS CLI installation
- Credential configuration
- Required permissions
- Region settings

## Additional Resources

- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [Terraform AWS Provider Authentication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
