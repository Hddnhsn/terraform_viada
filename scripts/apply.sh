#!/bin/bash
# Apply Terraform configuration

set -e

echo "🚀 Applying Terraform configuration..."

# Check if plan exists
if [ ! -f "tfplan" ]; then
    echo "❌ No plan file found!"
    echo "Please run './scripts/plan.sh' first to generate a plan."
    exit 1
fi

echo "⚠️  This will create/modify infrastructure in your AWS account."
read -p "Are you sure you want to continue? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "❌ Apply cancelled."
    exit 1
fi

# Apply the plan
echo "\n🔧 Applying changes..."
terraform apply tfplan

# Remove plan file after successful apply
rm -f tfplan

echo "\n✅ Infrastructure changes applied successfully!"
echo "\n📊 Run './scripts/output.sh' to see output values."
