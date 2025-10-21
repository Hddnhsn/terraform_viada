#!/bin/bash
# Format Terraform files

set -e

echo "🎨 Formatting Terraform files..."

terraform fmt -recursive

echo "✅ Formatting complete!"
