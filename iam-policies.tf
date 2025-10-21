# IAM Policies and Roles for Terraform Management
# This file is optional - only apply if you need to create IAM resources

# IAM Policy for Terraform User/Role with minimal required permissions
resource "aws_iam_policy" "terraform_policy" {
  count       = var.create_terraform_iam_policy ? 1 : 0
  name        = "${var.project_name}-terraform-policy"
  description = "Policy for Terraform to manage infrastructure"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VPCManagement"
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:DescribeVpcs",
          "ec2:ModifyVpcAttribute",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:DescribeSubnets",
          "ec2:ModifySubnetAttribute",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:DescribeInternetGateways",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:DescribeRouteTables",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Sid    = "NATGatewayManagement"
        Effect = "Allow"
        Action = [
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",
          "ec2:DescribeNatGateways",
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:DescribeAddresses"
        ]
        Resource = "*"
      },
      {
        Sid    = "StateManagement"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::*-terraform-state",
          "arn:aws:s3:::*-terraform-state/*"
        ]
      },
      {
        Sid    = "StateLocking"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/terraform-state-lock"
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-terraform-policy"
    }
  )
}

# IAM User for Terraform (optional - for programmatic access)
resource "aws_iam_user" "terraform_user" {
  count = var.create_terraform_iam_user ? 1 : 0
  name  = "${var.project_name}-terraform"
  path  = "/system/"

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-terraform-user"
      Description = "IAM user for Terraform automation"
    }
  )
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "terraform_user_policy" {
  count      = var.create_terraform_iam_user && var.create_terraform_iam_policy ? 1 : 0
  user       = aws_iam_user.terraform_user[0].name
  policy_arn = aws_iam_policy.terraform_policy[0].arn
}

# IAM Role for Terraform (for use with EC2, ECS, Lambda, etc.)
resource "aws_iam_role" "terraform_role" {
  count              = var.create_terraform_iam_role ? 1 : 0
  name               = "${var.project_name}-terraform-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "ecs-tasks.amazonaws.com",
            "lambda.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      },
      # Allow specific users/roles to assume this role
      {
        Effect = "Allow"
        Principal = {
          AWS = var.terraform_role_trusted_arns
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.project_name
          }
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-terraform-role"
    }
  )
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "terraform_role_policy" {
  count      = var.create_terraform_iam_role && var.create_terraform_iam_policy ? 1 : 0
  role       = aws_iam_role.terraform_role[0].name
  policy_arn = aws_iam_policy.terraform_policy[0].arn
}

# Instance profile for EC2 instances
resource "aws_iam_instance_profile" "terraform_profile" {
  count = var.create_terraform_iam_role ? 1 : 0
  name  = "${var.project_name}-terraform-profile"
  role  = aws_iam_role.terraform_role[0].name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-terraform-profile"
    }
  )
}

# Outputs for IAM resources
output "terraform_policy_arn" {
  description = "ARN of the Terraform IAM policy"
  value       = var.create_terraform_iam_policy ? aws_iam_policy.terraform_policy[0].arn : null
}

output "terraform_user_arn" {
  description = "ARN of the Terraform IAM user"
  value       = var.create_terraform_iam_user ? aws_iam_user.terraform_user[0].arn : null
}

output "terraform_role_arn" {
  description = "ARN of the Terraform IAM role"
  value       = var.create_terraform_iam_role ? aws_iam_role.terraform_role[0].arn : null
}

output "terraform_instance_profile_arn" {
  description = "ARN of the Terraform instance profile"
  value       = var.create_terraform_iam_role ? aws_iam_instance_profile.terraform_profile[0].arn : null
}
