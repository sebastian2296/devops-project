# AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Remote States
terraform {
  backend "s3" {}
}

data "terraform_remote_state" "networking" {
  backend   = "s3" 
  config    = {
    bucket  = var.tf_state_bucket_networking
    key     = "terraform-state/networking-infra/terraform.tfstate"
    region  = "us-east-1"
  }
}