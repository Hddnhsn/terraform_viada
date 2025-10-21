#!/bin/bash
# Refresh Terraform state

set -e

echo "🔄 Refreshing Terraform state..."

terraform refresh

echo "\n✅ State refreshed successfully!"
echo "Run './scripts/output.sh' to see updated output values."
