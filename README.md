# Viada Terraform Infrastructure

This repository contains Terraform configurations for managing cloud infrastructure for the Viada project.

## 📋 Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- AWS CLI configured with appropriate credentials
- Bash shell (for running helper scripts)

## 🏗️ Infrastructure Components

This configuration creates:

- **VPC** with customizable CIDR block
- **Public Subnets** across multiple availability zones
- **Private Subnets** across multiple availability zones
- **Internet Gateway** for public internet access
- **Route Tables** and associations
- **Security Groups** with basic web traffic rules

## 📁 Project Structure

```
.
├── main.tf                      # Main infrastructure resources
├── variables.tf                 # Variable definitions
├── outputs.tf                   # Output values
├── providers.tf                 # Provider configuration
├── terraform.tfvars.example     # Example variable values
├── .gitignore                   # Git ignore rules
├── scripts/
│   ├── init.sh                  # Initialize Terraform
│   ├── plan.sh                  # Generate execution plan
│   ├── apply.sh                 # Apply changes
│   ├── destroy.sh               # Destroy infrastructure
│   ├── format.sh                # Format Terraform files
│   ├── validate.sh              # Validate configuration
│   ├── output.sh                # Display outputs
│   └── refresh.sh               # Refresh state
└── README.md
```

## 🚀 Quick Start

### 1. Initialize Terraform

```bash
chmod +x scripts/*.sh
./scripts/init.sh
```

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Plan Changes

```bash
./scripts/plan.sh
```

### 4. Apply Configuration

```bash
./scripts/apply.sh
```

## 🛠️ Available Scripts

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

### Outputs

The configuration provides the following outputs:

- `vpc_id` - VPC identifier
- `vpc_cidr` - VPC CIDR block
- `public_subnet_ids` - List of public subnet IDs
- `private_subnet_ids` - List of private subnet IDs
- `internet_gateway_id` - Internet Gateway ID
- `security_group_id` - Main security group ID

## 🔒 Security Best Practices

1. **Never commit `terraform.tfvars`** - It may contain sensitive data
2. **Use AWS IAM roles** with minimal required permissions
3. **Enable S3 backend** for state management (see `main.tf`)
4. **Use state locking** with DynamoDB
5. **Review plans carefully** before applying

## 📝 Workflow

### Development Workflow

```bash
# 1. Make changes to .tf files
# 2. Format code
./scripts/format.sh

# 3. Validate
./scripts/validate.sh

# 4. Plan changes
./scripts/plan.sh

# 5. Review plan and apply
./scripts/apply.sh

# 6. View outputs
./scripts/output.sh
```

### Production Deployment

1. Create a new branch for changes
2. Test in dev environment first
3. Use pull requests for code review
4. Apply to production after approval

## 🔄 State Management

### Local State (Default)

State is stored locally in `terraform.tfstate` (excluded from git).

### Remote State (Recommended)

Uncomment the backend configuration in `main.tf`:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "viada/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

## 🐛 Troubleshooting

### Error: No plan file found
Run `./scripts/plan.sh` before `./scripts/apply.sh`

### Error: terraform.tfvars not found
Copy `terraform.tfvars.example` to `terraform.tfvars` and configure

### Permission denied when running scripts
Make scripts executable: `chmod +x scripts/*.sh`

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is private and proprietary.

## 👤 Maintainer

**Hddnhsn**
- GitHub: [@Hddnhsn](https://github.com/Hddnhsn)

---

**Note**: Always review and test infrastructure changes in a development environment before applying to production.
