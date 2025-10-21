#!/bin/bash
# Test AWS Authentication and Permissions

set -e

echo "🔐 Testing AWS Authentication..."
echo "================================="
echo

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed"
    echo "Please install it from: https://aws.amazon.com/cli/"
    exit 1
fi

echo "✅ AWS CLI is installed"
aws --version
echo

# Check AWS configuration
echo "📋 AWS Configuration:"
aws configure list
echo

# Test authentication
echo "🔍 Testing AWS Credentials..."
if aws sts get-caller-identity &> /dev/null; then
    echo "✅ AWS credentials are valid"
    echo
    echo "📊 Account Information:"
    aws sts get-caller-identity
    echo
else
    echo "❌ AWS credentials are invalid or not configured"
    echo
    echo "To configure AWS credentials, run:"
    echo "  aws configure"
    echo
    echo "Or set environment variables:"
    echo "  export AWS_ACCESS_KEY_ID=your-key"
    echo "  export AWS_SECRET_ACCESS_KEY=your-secret"
    echo "  export AWS_DEFAULT_REGION=us-east-1"
    exit 1
fi

# Check region
REGION=$(aws configure get region)
if [ -z "$REGION" ]; then
    echo "⚠️  No default region set"
    echo "Set a region with: aws configure set region us-east-1"
else
    echo "✅ Default region: $REGION"
fi
echo

# Test basic permissions
echo "🔑 Testing Basic Permissions..."
echo

echo "Testing VPC permissions..."
if aws ec2 describe-vpcs --max-results 1 &> /dev/null; then
    echo "  ✅ VPC read access"
else
    echo "  ❌ VPC read access denied"
fi

echo "Testing EC2 permissions..."
if aws ec2 describe-instances --max-results 1 &> /dev/null; then
    echo "  ✅ EC2 read access"
else
    echo "  ❌ EC2 read access denied"
fi

echo "Testing Security Group permissions..."
if aws ec2 describe-security-groups --max-results 1 &> /dev/null; then
    echo "  ✅ Security Group read access"
else
    echo "  ❌ Security Group read access denied"
fi

echo
echo "==============================="
echo "✅ Authentication test complete!"
echo
echo "💡 Next steps:"
echo "  1. Ensure you have necessary permissions for Terraform"
echo "  2. Review iam-policies.tf for required permissions"
echo "  3. Run './scripts/init.sh' to initialize Terraform"
