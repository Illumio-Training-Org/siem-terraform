terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "instruqt_participant_id" {
  type = string
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "siem_lab" {
  bucket        = "siem-lab-logs-${var.instruqt_participant_id}"
  force_destroy = true

  tags = {
    Name = "SIEM Lab Logs"
    Lab  = "siem-lab-s3-opensearch"
  }
}

resource "aws_s3_bucket_ownership_controls" "siem_lab" {
  bucket = aws_s3_bucket.siem_lab.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "siem_lab" {
  bucket                  = aws_s3_bucket.siem_lab.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "sample_syslog" {
  bucket = aws_s3_bucket.siem_lab.id
  key    = "logs/sample-syslog.log"
  source = "${path.module}/../sample-syslog.log"
  etag   = filemd5("${path.module}/../sample-syslog.log")
}

resource "aws_iam_user" "lab_user" {
  name = "siem-lab-user-${var.instruqt_participant_id}"
  path = "/lab/"
}

resource "aws_iam_access_key" "lab_user" {
  user = aws_iam_user.lab_user.name
}

resource "aws_iam_user_policy" "lab_s3_policy" {
  name = "siem-lab-s3-access"
  user = aws_iam_user.lab_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListObjectsV2"
        ]
        Resource = [
          aws_s3_bucket.siem_lab.arn,
          "${aws_s3_bucket.siem_lab.arn}/*"
        ]
      }
    ]
  })
}

output "s3_bucket_name" {
  value = aws_s3_bucket.siem_lab.bucket
}

output "s3_bucket_region" {
  value = "us-east-1"
}

output "aws_access_key_id" {
  value     = aws_iam_access_key.lab_user.id
  sensitive = true
}

output "aws_secret_access_key" {
  value     = aws_iam_access_key.lab_user.secret
  sensitive = true
}
