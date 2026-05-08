variable "site_name" {
  description = "Base name used for resources (e.g. S3 bucket will be named <site_name>-site)"
  type        = string
  default     = "gabymey.co.za"
}

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}
