terraform {
  backend "s3" {
    bucket = "matthew-account-state"
    key    = "gabymey-site/terraform.tfstate"
    region = "af-south-1"
  }
}
