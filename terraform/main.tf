terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_iam_group" "s3_support" {
  name = "S3-Support"
}

resource "aws_iam_group" "ec2_support" {
  name = "EC2-Support"
}

resource "aws_iam_group" "ec2_admin" {
  name = "EC2-Admin"
}

data "aws_iam_policy" "s3_readonly" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

data "aws_iam_policy" "ec2_readonly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_policy" "ec2_admin_policy" {
  name        = "EC2AdminBasic"
  description = "Allows EC2 View, Start, Stop"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "s3_attach" {
  group      = aws_iam_group.s3_support.name
  policy_arn = data.aws_iam_policy.s3_readonly.arn
}

resource "aws_iam_group_policy_attachment" "ec2_attach" {
  group      = aws_iam_group.ec2_support.name
  policy_arn = data.aws_iam_policy.ec2_readonly.arn
}

resource "aws_iam_group_policy_attachment" "ec2_admin_attach" {
  group      = aws_iam_group.ec2_admin.name
  policy_arn = aws_iam_policy.ec2_admin_policy.arn
}

resource "aws_iam_user" "user1" {
  name = "user-1"
}

resource "aws_iam_user" "user2" {
  name = "user-2"
}

resource "aws_iam_user" "user3" {
  name = "user-3"
}

resource "aws_iam_user_group_membership" "user1_group" {
  user = aws_iam_user.user1.name
  groups = [aws_iam_group.s3_support.name]
}

resource "aws_iam_user_group_membership" "user2_group" {
  user = aws_iam_user.user2.name
  groups = [aws_iam_group.ec2_support.name]
}

resource "aws_iam_user_group_membership" "user3_group" {
  user = aws_iam_user.user3.name
  groups = [aws_iam_group.ec2_admin.name]
}
