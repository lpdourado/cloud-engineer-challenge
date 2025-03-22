terraform {
  backend "s3" {
    bucket      = "backend-3274"
    key         = "env/dev/eu-west-1/cloud-engineer-challenge"
    region      = "eu-west-1"
  }
}