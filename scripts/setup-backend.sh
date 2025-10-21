#!/bin/bash
# Setup S3 backend for Terraform state management

set -e

echo "🪣 Setting up Terraform S3 Backend..."
echo "====================================="
echo

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured"
    echo "Run './scripts/test-auth.sh' first"
    exit 1
fi

# Get account ID and region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=${AWS_DEFAULT_REGION:-us-east-1}

echo "📊 AWS Account: $ACCOUNT_ID"
echo "🌍 Region: $REGION"
echo

# Prompt for bucket name
read -p "Enter S3 bucket name for Terraform state [terraform-state-$ACCOUNT_ID]: " BUCKET_NAME
BUCKET_NAME=${BUCKET_NAME:-terraform-state-$ACCOUNT_ID}

DYNAMODB_TABLE="terraform-state-lock"

echo
echo "Will create:"
echo "  📦 S3 Bucket: $BUCKET_NAME"
echo "  🔒 DynamoDB Table: $DYNAMODB_TABLE"
echo

read -p "Continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "❌ Setup cancelled"
    exit 1
fi

echo
echo "Creating resources..."
echo

# Create S3 bucket
echo "📦 Creating S3 bucket: $BUCKET_NAME"
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "  ⚠️  Bucket already exists"
else
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" \
        $([ "$REGION" != "us-east-1" ] && echo "--create-bucket-configuration LocationConstraint=$REGION")
    echo "  ✅ Bucket created"
fi

# Enable versioning
echo "  🔄 Enabling versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
echo "  ✅ Versioning enabled"

# Enable encryption
echo "  🔐 Enabling encryption..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'
echo "  ✅ Encryption enabled"

# Block public access
echo "  🚫 Blocking public access..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
echo "  ✅ Public access blocked"

# Create DynamoDB table for state locking
echo
echo "🔒 Creating DynamoDB table: $DYNAMODB_TABLE"
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$REGION" 2>/dev/null; then
    echo "  ⚠️  Table already exists"
else
    aws dynamodb create-table \
        --table-name "$DYNAMODB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "$REGION" \
        --tags Key=Project,Value=viada Key=ManagedBy,Value=Terraform
    
    echo "  ⏳ Waiting for table to be active..."
    aws dynamodb wait table-exists --table-name "$DYNAMODB_TABLE" --region "$REGION"
    echo "  ✅ Table created"
fi

echo
echo "================================"
echo "✅ Backend setup complete!"
echo
echo "📝 Add this to your main.tf backend configuration:"
echo
cat <<EOF
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "viada/terraform.tfstate"
    region         = "$REGION"
    encrypt        = true
    dynamodb_table = "$DYNAMODB_TABLE"
  }
}
EOF
echo
echo "💡 Then run: terraform init -migrate-state"
