terraform {
  backend "s3" {
    bucket = "backend-3274"
    key = "env/dev/eu-west-1/cloud-engineer-challenge.tfstate"
    region = "eu-west-1"
    encrypt = true
  }
}