terraform {
  required_version = "~>1.13.3"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.14.1"
    }
  }
  backend "s3" {
    bucket = "terraform-backend-project-terraform-vpc-github-actions"
    key = "lab/terraform.tfstate"
    region = "ap-south-1"
    
  }
}

provider "aws" {
  # Configuration options
  #profile = "default"
  region = "ap-south-1"
}