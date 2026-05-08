terraform {
  backend "s3" {
    bucket = "matthew-account-state"
    key    = "gabymey-site/terraform.tfstate"
    region = "us-east-1"
  }
}
