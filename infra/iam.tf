# ---------------------------------------------------------------------------
# IAM policy for the existing Github-Actions user
# ---------------------------------------------------------------------------
#
# This references the EXISTING IAM user "Github-Actions".
# It does NOT create the user — only attaches a policy to it.

data "aws_iam_user" "github_actions" {
  user_name = "Github-Actions"
}

resource "aws_iam_policy" "github_actions_deploy" {
  name        = "${var.site_name}-github-actions-deploy"
  description = "Allows Github Actions to deploy the ${var.site_name} site to S3 and invalidate CloudFront"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # S3 sync: list, put, delete objects in the site bucket
        Sid    = "S3SiteDeploy"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.site.arn,
          "${aws_s3_bucket.site.arn}/*"
        ]
      },
      {
        # CloudFront cache invalidation after deploy
        Sid    = "CloudFrontInvalidate"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = aws_cloudfront_distribution.site.arn
      },
      {
        # Terraform remote state: read/write to the state bucket
        # Replace ACCOUNT_ID with your 12-digit AWS account ID
        Sid    = "TerraformStateAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::gabrielle-account-state",
          "arn:aws:s3:::gabrielle-account-state/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "github_actions_deploy" {
  user       = data.aws_iam_user.github_actions.user_name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}
