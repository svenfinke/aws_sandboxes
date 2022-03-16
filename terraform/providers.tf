terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
  profile = "sva-org"
}

provider "aws" {
  alias = "aws-master"
  region = "eu-central-1"
  profile = "sva"
}