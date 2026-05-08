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

# Bucket policy: allow CloudFront OAC to read objects (s3:GetObject).
# GitHub Actions S3 access is handled via the IAM identity policy in iam.tf —
# a bucket policy statement is not needed for same-account IAM principals.
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
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
      }
    ]
  })

  # The distribution must exist before we can reference its ARN in the policy
  depends_on = [aws_cloudfront_distribution.site]
}
