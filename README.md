# Viada Terraform Infrastructure

This repository contains Terraform configurations for managing cloud infrastructure for the Viada project.

## 📋 Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- Bash shell (for running helper scripts)
- AWS Account with appropriate IAM permissions

## 🔐 Authentication Setup

**⚠️ This is required before using Terraform!**

See the comprehensive [Authentication Guide](docs/AUTHENTICATION.md) for detailed instructions on:
- AWS CLI configuration
- Multiple authentication methods (profiles, environment variables, IAM roles)
- Creating IAM users/roles for Terraform
- Security best practices
- CI/CD integration

### Quick Authentication Setup:

```bash
# 1. Install AWS CLI (if not already installed)
# macOS: brew install awscli
# Linux/Windows: See docs/AUTHENTICATION.md

# 2. Configure credentials
aws configure

# 3. Test authentication
./scripts/test-auth.sh

# 4. (Optional) Setup S3 backend for remote state
./scripts/setup-backend.sh
```

**Available Authentication Methods:**
- AWS CLI Configuration (recommended for local development)
- Environment Variables (good for CI/CD)
- AWS Profiles (for multiple accounts)
- IAM Roles (for AWS services)
- AWS SSO

## 🏗️ Infrastructure Components

This configuration creates:

- **VPC** with customizable CIDR block
- **Public Subnets** across multiple availability zones
- **Private Subnets** across multiple availability zones
- **Internet Gateway** for public internet access
- **Route Tables** and associations
- **Security Groups** with basic web traffic rules
- **IAM Policies, Users, and Roles** (optional) for Terraform management

## 📁 Project Structure

```
.
├── main.tf                      # Main infrastructure resources
├── variables.tf                 # Variable definitions
├── outputs.tf                   # Output values
├── providers.tf                 # Provider configuration
├── iam-policies.tf              # IAM resources for Terraform
├── iam-variables.tf             # IAM-related variables
├── terraform.tfvars.example     # Example variable values
├── .gitignore                   # Git ignore rules
├── docs/
│   └── AUTHENTICATION.md        # Authentication guide
├── scripts/
│   ├── init.sh                  # Initialize Terraform
│   ├── plan.sh                  # Generate execution plan
│   ├── apply.sh                 # Apply changes
│   ├── destroy.sh               # Destroy infrastructure
│   ├── format.sh                # Format Terraform files
│   ├── validate.sh              # Validate configuration
│   ├── output.sh                # Display outputs
│   ├── refresh.sh               # Refresh state
│   ├── test-auth.sh             # Test AWS authentication
│   └── setup-backend.sh         # Setup S3 backend
└── README.md
```

## 🚀 Quick Start

### 1. Setup Authentication

```bash
# Configure AWS credentials
aws configure

# Test authentication
chmod +x scripts/*.sh
./scripts/test-auth.sh
```

### 2. Initialize Terraform

```bash
./scripts/init.sh
```

### 3. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 4. Plan Changes

```bash
./scripts/plan.sh
```

### 5. Apply Configuration

```bash
./scripts/apply.sh
```

## 🛠️ Available Scripts

### `test-auth.sh` ⭐ NEW
Tests AWS authentication and required permissions.

```bash
./scripts/test-auth.sh
```

### `setup-backend.sh` ⭐ NEW
Sets up S3 bucket and DynamoDB table for remote state management.

```bash
./scripts/setup-backend.sh
```

### `init.sh`
Initializes Terraform and downloads required providers.

```bash
./scripts/init.sh
```

### `plan.sh`
Validates configuration and generates an execution plan.

```bash
./scripts/plan.sh
```

### `apply.sh`
Applies the Terraform plan to create/update infrastructure.

```bash
./scripts/apply.sh
```

### `destroy.sh`
Destroys all Terraform-managed infrastructure.

```bash
./scripts/destroy.sh
```

### `format.sh`
Formats all Terraform files to canonical format.

```bash
./scripts/format.sh
```

### `validate.sh`
Validates the Terraform configuration.

```bash
./scripts/validate.sh
```

### `output.sh`
Displays all Terraform outputs.

```bash
./scripts/output.sh
```

### `refresh.sh`
Refreshes the Terraform state.

```bash
./scripts/refresh.sh
```

## ⚙️ Configuration

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Project name | `viada` |
| `environment` | Environment (dev/staging/prod) | `dev` |
| `aws_region` | AWS region | `us-east-1` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `public_subnet_cidrs` | Public subnet CIDRs | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_subnet_cidrs` | Private subnet CIDRs | `["10.0.10.0/24", "10.0.11.0/24"]` |
| `availability_zones` | Availability zones | `["us-east-1a", "us-east-1b"]` |

### IAM Configuration Variables (Optional)

| Variable | Description | Default |
|----------|-------------|---------|
| `create_terraform_iam_policy` | Create IAM policy for Terraform | `false` |
| `create_terraform_iam_user` | Create IAM user for Terraform | `false` |
| `create_terraform_iam_role` | Create IAM role for Terraform | `false` |
| `terraform_role_trusted_arns` | ARNs allowed to assume Terraform role | `[]` |

### Outputs

The configuration provides the following outputs:

- `vpc_id` - VPC identifier
- `vpc_cidr` - VPC CIDR block
- `public_subnet_ids` - List of public subnet IDs
- `private_subnet_ids` - List of private subnet IDs
- `internet_gateway_id` - Internet Gateway ID
- `security_group_id` - Main security group ID
- `terraform_policy_arn` - IAM policy ARN (if created)
- `terraform_user_arn` - IAM user ARN (if created)
- `terraform_role_arn` - IAM role ARN (if created)

## 🔒 Security Best Practices

1. **Never commit credentials** 
   - `terraform.tfvars` is gitignored
   - Never hardcode credentials in `.tf` files
   - Use AWS profiles or environment variables

2. **Use IAM roles with minimal permissions**
   - See `iam-policies.tf` for example policies
   - Follow principle of least privilege

3. **Enable remote state management**
   - Use S3 backend with encryption
   - Enable state locking with DynamoDB
   - Run `./scripts/setup-backend.sh` to set up

4. **Review plans carefully** before applying

5. **Rotate access keys regularly**

6. **Enable MFA** for production accounts

## 📝 Workflow

### Development Workflow

```bash
# 1. Ensure authentication is working
./scripts/test-auth.sh

# 2. Make changes to .tf files

# 3. Format code
./scripts/format.sh

# 4. Validate
./scripts/validate.sh

# 5. Plan changes
./scripts/plan.sh

# 6. Review plan and apply
./scripts/apply.sh

# 7. View outputs
./scripts/output.sh
```

### Production Deployment

1. Setup remote state backend with `./scripts/setup-backend.sh`
2. Create a new branch for changes
3. Test in dev environment first
4. Use pull requests for code review
5. Apply to production after approval
6. Tag releases

## 🔄 State Management

### Local State (Default)

State is stored locally in `terraform.tfstate` (excluded from git).

**⚠️ Not recommended for teams or production!**

### Remote State (Recommended)

Use the setup script to create S3 backend:

```bash
./scripts/setup-backend.sh
```

This creates:
- S3 bucket with versioning and encryption
- DynamoDB table for state locking
- Proper security configurations

Then update `main.tf` with the backend configuration provided by the script.

## 🐛 Troubleshooting

### Error: No valid credential sources
```bash
# Check configuration
aws configure list

# Test credentials
./scripts/test-auth.sh
```

### Error: Access Denied
- Verify IAM permissions
- Check if MFA is required
- Review `docs/AUTHENTICATION.md`

### Error: No plan file found
Run `./scripts/plan.sh` before `./scripts/apply.sh`

### Error: terraform.tfvars not found
Copy `terraform.tfvars.example` to `terraform.tfvars` and configure

### Permission denied when running scripts
Make scripts executable: `chmod +x scripts/*.sh`

## 📚 Additional Resources

- [Authentication Guide](docs/AUTHENTICATION.md)
- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly in dev environment
5. Submit a pull request

## 📄 License

This project is private and proprietary.

## 👤 Maintainer

**Hddnhsn**
- GitHub: [@Hddnhsn](https://github.com/Hddnhsn)

---

**Note**: Always review and test infrastructure changes in a development environment before applying to production. Ensure authentication is properly configured before running any Terraform commands.
