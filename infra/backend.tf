terraform {
  backend "s3" {
    bucket = "gabrielle-account-state"
    key    = "gabrielle-site/terraform.tfstate"
    region = "us-east-1"
  }
}
