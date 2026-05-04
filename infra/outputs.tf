output "cloudfront_domain_name" {
  description = "The CloudFront distribution domain name. Use this as your site URL until a custom domain is configured."
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the site files."
  value       = aws_s3_bucket.site.id
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID — needed for the CF_DIST_ID GitHub Actions secret."
  value       = aws_cloudfront_distribution.site.id
}
