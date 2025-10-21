#!/bin/bash
# Validate Terraform configuration

set -e

echo "✅ Validating Terraform configuration..."

# Format check
echo "\n🎨 Checking format..."
terraform fmt -check -recursive

# Validate syntax and configuration
echo "\n🔍 Validating syntax..."
terraform validate

echo "\n✅ Validation complete! Configuration is valid."
