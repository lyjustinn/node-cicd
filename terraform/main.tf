terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    archive = {
      source = "hashicorp/archive"
    }
  }
}

provider "aws" {
  region = var.region
  shared_credentials_file = "~/.aws/credentials"
}

provider "archive" {
  
}