terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.14.0"
    }
    
  local = {
      source = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}