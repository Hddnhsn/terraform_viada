#!/bin/bash
# Initialize Terraform configuration

set -e

echo "🚀 Initializing Terraform..."

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first."
    echo "Visit: https://www.terraform.io/downloads"
    exit 1
fi

# Check Terraform version
echo "📦 Terraform version:"
terraform version

# Initialize Terraform
echo "\n🔧 Running terraform init..."
terraform init

echo "\n✅ Terraform initialization complete!"
echo "\n📝 Next steps:"
echo "  1. Copy terraform.tfvars.example to terraform.tfvars"
echo "  2. Update terraform.tfvars with your values"
echo "  3. Run './scripts/plan.sh' to see planned changes"
echo "  4. Run './scripts/apply.sh' to create infrastructure"
