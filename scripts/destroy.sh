#!/bin/bash
# Destroy Terraform-managed infrastructure

set -e

echo "⚠️  WARNING: This will DESTROY all Terraform-managed infrastructure!"
echo "This action cannot be undone."
echo
read -p "Type 'destroy' to confirm: " -r
echo

if [[ $REPLY != "destroy" ]]; then
    echo "❌ Destroy cancelled."
    exit 1
fi

echo "\n🗑️  Destroying infrastructure..."
terraform destroy

echo "\n✅ Infrastructure destroyed successfully."
