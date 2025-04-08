terraform {
  backend "s3" {
    bucket         = "renovaro-general-purpose"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}
