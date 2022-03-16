terraform {
  backend "s3" {
    bucket = "sva-cloud-sandboxes-poc-state"
    key    = "terraform"
    region = "eu-central-1"
  }
}
