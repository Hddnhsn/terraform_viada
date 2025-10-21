#!/bin/bash
# Display Terraform outputs

set -e

echo "📊 Terraform Outputs:"
echo "==================="
echo

terraform output

echo
echo "💡 Tip: Use 'terraform output <output_name>' to get specific values."
