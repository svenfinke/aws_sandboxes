# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket  = "sva-cloud-sandboxes-poc-state"
    encrypt = true
    key     = "step-functions/terraform.tfstate"
    profile = "sva"
    region  = "eu-central-1"
  }
}