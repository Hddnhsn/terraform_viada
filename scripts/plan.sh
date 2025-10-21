#!/bin/bash
# Plan Terraform changes

set -e

echo "📋 Planning Terraform changes..."

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "⚠️  terraform.tfvars not found!"
    echo "Please copy terraform.tfvars.example to terraform.tfvars and update with your values."
    exit 1
fi

# Format check
echo "🎨 Checking Terraform formatting..."
terraform fmt -check || {
    echo "⚠️  Files need formatting. Run 'terraform fmt' to fix."
}

# Validate configuration
echo "\n✅ Validating Terraform configuration..."
terraform validate

# Generate plan
echo "\n📊 Generating execution plan..."
terraform plan -out=tfplan

echo "\n✅ Plan generated successfully!"
echo "Review the plan above. If it looks good, run './scripts/apply.sh' to apply changes."
