# ---------------------------------------------------------------------------
# S3 bucket for static site assets
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "site" {
  bucket = "${var.site_name}"

  tags = {
    Project = var.site_name
  }
}

# Block all public access — CloudFront accesses via OAC, not public URLs
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning so accidental deployments can be rolled back
resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket policy:
#   1. Allow CloudFront OAC to read objects (s3:GetObject)
#   2. Allow the Github-Actions IAM user to sync files (put / delete / list)
#
# IMPORTANT: Replace ACCOUNT_ID below with your actual 12-digit AWS account ID
#            before running terraform apply.
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Allow CloudFront (via OAC) to read any object in the bucket
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.site.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.site.arn
          }
        }
      },
      {
        # Allow Github-Actions IAM user to deploy the site
        # Replace ACCOUNT_ID with your 12-digit AWS account ID
        Sid    = "AllowGithubActionsSync"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::ACCOUNT_ID:user/Github-Actions"
        }
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.site.arn,
          "${aws_s3_bucket.site.arn}/*"
        ]
      }
    ]
  })

  # The distribution must exist before we can reference its ARN in the policy
  depends_on = [aws_cloudfront_distribution.site]
}
