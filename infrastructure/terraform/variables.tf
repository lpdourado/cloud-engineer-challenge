variable "aws_region" {
  default = "eu-west-1"
}

variable "s3_bucket_main" {
  default = "cloud-engineer-challenge-main-api"
}

variable "s3_bucket_aux" {
  default = "cloud-engineer-challenge-aux-service"
}

variable "parameter_store_name" {
  default = "/cloud-engineer-challenge/app-version"
}